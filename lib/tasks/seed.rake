namespace :load do
  desc 'Seed test data'
  task all: :environment do
    begin
      ["load:seed_guardians", "load:seed_photo_message"].each do |t|
        Rake::Task[t].execute
        puts "#{t} completed"
      end
    end
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
        print "Failed to create a family - #{family.errors.full_messages}"
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
        role_id: 4,
        practice_id: 1,
        phone: '1234567890'
      )

      if guardian_male.valid?
        print "*"
      else
        print "x"
        print "Failed to seed guardian user - #{guardian_male.errors.full_messages}"
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
        role_id: 4,
        practice_id: 1,
        phone: '1234567890'
      )

      if guardian_female.valid?
        print "*"
      else
        print "x"
        print "Failed to seed guardian user - #{guardian_female.errors.full_messages}"
        false
      end

      f = index%3 + 1

      (0...f).each do |i|
        if patient = family.patients.create!(
          first_name: "Child#{i}",
          middle_initial: "M.",
          last_name: last_name,
          sex: "F",
          birth_date: i.years.ago,
          role_id: 6
        )
          print "*"
        else
          print "x"
          print "Failed to seed patient user - #{patient.errors.full_messages}"
          false
        end
      end

      puts "Created family #{family.id.to_s} with #{f} children."
    end
  end

  desc "Seed photo message in conversations."
  task seed_photo_message: :environment do
    image = Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', '404-baby.png'))
    range = Conversation.all.length/2
    Conversation.all[0..range].each do |conversation|
      message = conversation.messages.create( body: "This is a smiling baby",
                                              sender: conversation.family.primary_guardian,
                                              type_name: "image",
                                              message_photo_attributes: { image: image } )

      if message.valid?
        print "*"
      else
        print "x"
        print "Failed to add photo message for conversation with id #{conversation.id}"
      end
    end
  end
end
