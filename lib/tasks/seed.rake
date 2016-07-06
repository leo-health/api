namespace :load do
  desc 'Seed test data'
  task all: :environment do
    begin
      ["load:seed_guardians", "load:seed_messages"].each do |t|
        Rake::Task[t].execute
        puts "#{t} completed"
      end
    end
  end

  desc "Seed Jonathan Bush family"
  task bush: :environment do
    family = Family.create!
    family.exempt_membership!
    user = User.create!(
      first_name: "Jonathan",
      last_name: "Bush",
      family: family,
      email: "adam+1997@leohealth.com",
      password: "password",
      role: Role.guardian,
      practice_id: 1,
      phone: "9735172669",
      vendor_id: "bush_vendor_id"
    )
    user.set_complete!
    Delayed::Job.where(queue: "registration_email").order("created_at DESC").first.destroy
    Delayed::Job.where(queue: "notification_email").order("created_at DESC").first.destroy
    family.patients.create!(
      first_name: "Jeb",
      last_name: "Bush",
      sex: "M",
      birth_date: Date.new(2016,4,1)
    )
    family.patients.create!(
      first_name: "George",
      last_name: "Bush",
      sex: "M",
      birth_date: Date.new(2016,3,1)
    )
    family.patients.create!(
      first_name: "Athena",
      last_name: "Health",
      sex: "F",
      birth_date: Date.new(1997,3,31)
    )
  end

  desc "Seed sample guardian users with conversations."
  task seed_guardians: :environment do
    last_names = ['Einstein', 'Turing', 'Lovelace', 'Tesla', 'Curie', 'Planck', 'Faraday', 'Brown', 'Hopper', 'Galilei', 'Wright', 'Pasteur', 'Euler', 'Braun', 'Darwin']
    male_first_names = ['Alan', 'Albert', 'Alexandar', 'Alfred', 'Aldo', 'George', 'Max', 'Nikola', 'Michael', 'Henri', 'Isaac', 'Ivan', 'Jack', 'Stephen', 'Charles']
    female_first_names = ['Ada', 'Dorothy', 'Grace', 'Marie', 'Rosalind', 'Mary', 'Katharine', 'Lynn', 'Jane', 'Sally', 'Jocelyn', 'Rita', 'Rachel', 'Irene', 'Agnes']

    last_names.each_with_index do |last_name, index|
      family = Family.create!
      family.exempt_membership!

      if family.save
        print "*"
      else
        print "x"
        print "Failed to create a family - #{family.errors.full_messages.first}"
        false
      end

      male_first_name = male_first_names[index]

      guardian_male = User.create!(
        first_name: male_first_name,
        last_name: last_name,
        sex: "M",
        family: family,
        password: "password",
        email: "#{male_first_name}@leo.com",
        role: Role.guardian,
        practice_id: 1,
        phone: '1234567890',
        vendor_id: "male_vendor_id#{index}"
      )

      if guardian_male.valid?
        guardian_male.set_complete!
        print "*"
      else
        print "x"
        print "Failed to seed guardian user - #{guardian_male.errors.full_messages.first}"
        false
      end

      sleep 1

      female_first_name = female_first_names[index]
      guardian_female = User.create!(
        first_name: female_first_name,
        last_name: last_name,
        sex: "F",
        family: family,
        password: "password",
        email: "#{female_first_name}@leo.com",
        role: Role.guardian,
        practice_id: 1,
        phone: '1234567890',
        vendor_id: "female_vendor_id#{index}"
      )

      if guardian_female.valid?
        guardian_female.set_complete!
        print "*"
      else
        print "x"
        print "Failed to seed guardian user - #{guardian_female.errors.full_messages.first}"
        false
      end

      f = index%3 + 1

      (0...f).each do |i|
        if patient = family.patients.create!(
          first_name: "Child#{i}",
          middle_initial: "M.",
          last_name: last_name,
          sex: "F",
          birth_date: i.years.ago
        )
          print "*"
        else
          print "x"
          print "Failed to seed patient user - #{patient.errors.full_messages.first}"
          false
        end
      end

      puts "Created family #{family.id.to_s} with #{f} children."
    end
  end


  desc "Seed messages in conversation to test pagination"
  task seed_messages: :environment do
    if conversation = Conversation.first
      primary_guardian = conversation.family.primary_guardian
      image = Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', '404-baby.png'))

      100.times do |i|
        if i%25 == 0
          message = conversation.messages.create( sender: primary_guardian,
                                                  type_name: "image",
                                                  message_photo_attributes: { image: image } )
        else
          message = conversation.messages.create( body: "Hello World!", type_name: "text", sender: primary_guardian )
        end

        if message.valid?
          print "*"
        else
          print "x"
          print "failed to create message "
        end
      end
    else
      print "x"
      print "Fail to seed messages, not conversation existing"
    end
  end

  desc "Seed test patients for front end"
  task seed_patients: :environment do
    practice = Practice.find_or_create_by(name: :test_practice)
    guardian_role = Role.find_or_create_by(name: :guardian)

    primary_guardian = {
      first_name: "Kung",
      last_name: "Wong",
      email: "kw@test.com",
      password: "password",
      role: guardian_role,
      practice_id: practice,
      phone: "3213212315",
      vendor_id: "kw_vendor_id",
      complete_status: "complete"
    }

    secondary_guardian = {
      first_name: "Gigi",
      last_name: "Wong",
      email: "gigiw@test.com",
      password: "password",
      role: guardian_role,
      practice_id: practice,
      phone: "3213212312",
      vendor_id: "gigi_vendor_id",
      complete_status: "complete"
    }

    if (guardian = User.find_by(email: primary_guardian[:email])) && guardian.update_attributes(primary_guardian.except(:password))
      puts "successfully updated primary guardian information"
    else
      guardian = User.create(primary_guardian)
      if guardian.valid?
        puts "successfully create primary guardian"
      else
        puts "failed to create primary guardian"
        next
      end
    end

    if guardian.family.try(:renew_membership)
      if (second_guardian = User.find_by(email: secondary_guardian[:email])) && second_guardian.update_attributes(secondary_guardian.except(:password))
        puts "successfully updated secondary guardian information"
      else
        second_guardian = User.create(secondary_guardian.merge(family: guardian.family))
        if second_guardian.valid?
          puts "successfully create secondary guardian"
        else
          puts "failed to create secondary guardian"
          next
        end
      end
    else
      puts "failed to upgrade the family"
      next
    end

    last_names = {
      '5_days' => {days: 5.days, height: "52.99", weight: "4214.52"},
      '2_week_wc' => {days: 14.days, height: "53.45", weight: "4723.34"},
      '3_week_wc' => {days: 21.days, height: "55.87", weight: "5146.45"},
      '1_month' => {days: 1.months, height: "57.93", weight: "5542.93"},
      '2_month' => {days: 2.months, height: "61.72", weight: "6798.35"},
      '4_month' => {days: 4.months, height: "67.31", weight: "8412.60"},
      '6_month' => {days: 6.months, height: "71.14", weight: "9481.94"},
      '9_month' => {days: 9.months, height: "75.66", weight: "1063.06"},
      '12_month' => {days: 12.months, height: "79.66", weight: "11535.26"},
      '15_month' => {days: 15.months, height: "83.31", weight: "12348.91"},
      '18_month' => {days: 18.months, height: "86.69", weight: "13129.06"},
      '2_years' => {days: 2.years, height: "92.84", weight: "14667.53"},
      '2_½_years' => {days: 30.months, height: "20", weight: "16343.95"},
      '3_years' => {days: 3.years, height: "20", weight: "17510.93"},
      '4_years' => {days: 4.years, height: "20", weight: "20283.39"},
      '5_years' => {days: 5.years, height: "20", weight: "23508.33"},
      '6_years' => {days: 6.years, height: "20", weight: "27033.08"},
      '7_years' => {days: 7.years, height: "20", weight: "30901.78"},
      '8_years' => {days: 8.years, height: "20", weight: "35289.55"},
      '9_years' => {days: 9.years, height: "20", weight: "40360.69"},
      '10_years' => {days: 10.years, height: "20", weight: "46157.53"},
      '11_years' => {days: 11.years, height: "20", weight: "52556.02"},
      '12_years' => {days: 12.years, height: "20", weight: "59303.56"},
      '13_years' => {days: 13.years, height: "20", weight: "66103.58"},
      '14_years' => {days: 14.years, height: "20", weight: "72686.81"},
      '15_years' => {days: 15.years, height: "20", weight: "78826.58"},
      '16_years' => {days: 16.years, height: "20", weight: "84292.28"},
      '17_years' => {days: 17.years, height: "20", weight: "88795.27"},
      '18_years' => {days: 18.years, height: "20", weight: "92047.64"},
      '19_years' => {days: 19.years, height: "20", weight: "93714.31"},
      '20_years' => {days: 20.years, height: "20", weight: "94542.39"},
      '21_years' => {days: 21.years, height: "20", weight: "95724.37"},
    }

    current_time = Time.now
    last_names.each_with_index do |(name, attributes), index|
      guardian.family.patients.destroy_all
      patient = Patient.create(
          first_name: "Baby",
          last_name: name,
          sex: "M",
          family: guardian.family,
          birth_date: current_time - attributes[:days]
      )

      if patient.valid?
        puts "successfully create patient #{name}"
        patient.vitals.destroy_all
        (index + 1).times do |i|
          time_stamp = patient.birth_date + last_names[last_names.keys[i]][:days]
          patient.vitals.create(
            [
             {
               athena_id: 0, taken_at: time_stamp,
               measurement: "VITALS.HEIGHT",
               value: last_names[last_names.keys[i]][:height],
               updated_at: time_stamp,
               created_at: time_stamp
             },

             {
               athena_id: 0,
               taken_at: time_stamp,
               measurement: "VITALS.HEIGHT",
               value: last_names[last_names.keys[i]][:weight],
               updated_at: time_stamp,
               created_at: time_stamp
             }
            ]
          )
        end
        if patient.vitals.count == (index + 1) * 2
          puts "successfully created height and weight records for patient #{name}"
        else
          puts "failed to created height and weight records for patient #{name}"
        end
      else
        puts "failed to create patient #{name}"
      end
    end

    if ENV['delete_twenty_percent']
      Patient.where(family: guardian.family).each do |patient|
        if (count = patient.vitals.count/5) && count > 0
          count.times do
            patient.vitals.sample.destroy
          end
        end
      end
      puts "deleted 20% vital records of patients"
    end

    if ENV['transferred_patients']
      Patient.where(family: guardian.family).each do |patient|
        half_life_span = (current_time.to_date - patient.birth_date).to_i/2
        patient.vitals.where(created_at: (current_time - half_life_span.days)..current_time).destroy_all
      end
      puts "deleted vital records from first life span"
    end
  end
end
