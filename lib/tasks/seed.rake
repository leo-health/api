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
        end
      end
    else
      puts "failed to upgrade the family"
    end

    # last_names = {
    #   '5_days' => Time.now - 5.days,
    #   '2_week_wc' => Tine.now - 14.days,
    #   '3_week_wc' => Tine.now - 21.days,
    #   '1_month' => Time.now - 1.months,
    #   '2_month' => Time.now - 2.months,
    #   '4_month' => Time.now - 4.months,
    #   '6_month' => Time.now - 6.months,
    #   '9_month' => Time.now - 9.months,
    #   '12_month' => Time.now - 12.months,
    #   '15_month' => Time.now - 15.months,
    #   '18_month' => Time.now - 18.months,
    #   '2_years' => Time.now - 2.years,
    #   '2_½_years' => Time.now - 30.months,
    #   '3_years' => Time.now - 3.years,
    #   '4_years' => Time.now - 4.years,
    #   '5_years' => Time.now - 5.years,
    #   '6_years' => Time.now - 6.years,
    #   '7_years' => Time.now - 7.years,
    #   '8_years' => Time.now - 8.years,
    #   '9_years' => Time.now - 9.years,
    #   '10_years' => Time.now - 10.years,
    #   '11_years' => Time.now - 11.years,
    #   '12_years' => Time.now - 12.years,
    #   '13_years' => Time.now - 13.years,
    #   '14_years' => Time.now - 14.years,
    #   '15_years' => Time.now - 15.years,
    #   '16_years' => Time.now - 16.years,
    #   '17_years' => Time.now - 17.years,
    #   '18_years' => Time.now - 18.years,
    #   '19_years' => Time.now - 19.years,
    #   '20_years' => Time.now - 20.years,
    #   '21_years' => Time.now - 21.years
    # }

    # last_names.keys.each do |name|
    #   Patient.where(first_name: "Bae", last_name: name, )
    # end
  end
end
