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
    Delayed::Job.where(queue: "registration_email").order("created_at DESC").first.try(:destroy)
    Delayed::Job.where(queue: "notification_email").order("created_at DESC").first.try(:destroy)
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
      family = Family.new

      if family.save
        print "*"
      else
        print "x"
        print "Failed to create a family - #{family.errors.full_messages.first}"
        false
      end

      male_first_name = male_first_names[index]

      guardian_male = family.guardians.create!(
        first_name: male_first_name,
        middle_initial: "E",
        last_name: last_name,
        sex: "M",
        password: "password",
        email: "#{male_first_name}@leo.com",
        role: Role.find_by(name: :guardian),
        practice_id: 1,
        phone: '1234567890',
        vendor_id: "male_vendor_id#{index}"
      )

      if guardian_male.valid?
        print "*"
      else
        print "x"
        print "Failed to seed guardian user - #{guardian_male.errors.full_messages.first}"
        false
      end

      sleep 1

      female_first_name = female_first_names[index]
      guardian_female = family.guardians.create!(
        first_name: female_first_name,
        middle_initial: "S",
        last_name: last_name,
        sex: "F",
        password: "password",
        email: "#{female_first_name}@leo.com",
        role: Role.find_by(name: :guardian),
        practice_id: 1,
        phone: '1234567890',
        vendor_id: "female_vendor_id#{index}"
      )

      if guardian_female.valid?
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
end
