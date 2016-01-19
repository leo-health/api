
namespace :load do

  desc 'Seed test data'
  task all: :environment do
    begin
      ["load:seed_staff", "load:seed_guardians", "load:seed_photo_message"].each do |t|
        Rake::Task[t].execute
        puts "#{t} completed"
      end
    end
  end

  desc "Seed the database with staff users"
  task seed_staff: :environment do

    staff = {
      bot: {
          first_name: "Leo",
          last_name: "Bot",
          birth_date: 48.years.ago.to_s,
          sex: "M",
          email: "leo_bot@leohealth.com",
          password: "password",
          password_confirmation: "password",
          role_id: 7,
          practice_id: 1,
          phone: '1234567890'
      },

      financial: {
          first_name: "Financial",
          last_name: "User",
          birth_date: 48.years.ago.to_s,
          sex: "M",
          email: "financial_user@leohealth.com",
          password: "password",
          password_confirmation: "password",
          role_id: 1,
          practice_id: 1,
          phone: '1234567890',
      },

      clinical_support: {
          first_name: "Clinical Support",
          last_name: "User",
          birth_date: 48.years.ago.to_s,
          sex: "M",
          email: "clinical_support_user@leohealth.com",
          password: "password",
          password_confirmation: "password",
          role_id: 2,
          practice_id: 1,
          phone: '1234567890',
      },

      customer_service: {
          first_name: "Customer Service",
          last_name: "User",
          birth_date: 48.years.ago.to_s,
          sex: "M",
          email: "customer_service_user@leohealth.com",
          password: "password",
          password_confirmation: "password",
          role_id: 3,
          practice_id: 1,
          phone: '1234567890',
      },

      hgold: {
          first_name: "Erin",
          last_name: "Gold",
          birth_date: 48.years.ago.to_s,
          sex: "F",
          email: "hgold@leohealth.com",
          password: "password",
          password_confirmation: "password",
          role_id: 5,
          practice_id: 1,
          athena_id: 3,
          athena_department_id: 2,
          specialties: "",
          phone: '1234567890',
          credentials: ["PNP"]
      },

      vriese: {
          title: "Dr.",
          first_name: "Victoria",
          last_name: "Riese",
          birth_date: 48.years.ago.to_s,
          sex: "F",
          email: "victoria@leohealth.com",
          password: "password",
          password_confirmation: "password",
          role_id: 5,
          practice_id: 1,
          athena_id: 4,
          athena_department_id: 2,
          specialties: "",
          phone: '1234567890',
          credentials: ["MD"]
      }
    }

    default_schedule = {
      description: "Default Schedule",
      active: true,
      monday_start_time: "09:00",
      monday_end_time: "18:00",
      tuesday_start_time: "09:00",
      tuesday_end_time: "18:00",
      wednesday_start_time: "09:00",
      wednesday_end_time: "18:00",
      thursday_start_time: "09:00",
      thursday_end_time: "18:00",
      friday_start_time: "09:00",
      friday_end_time: "18:00",
      saturday_start_time: "00:00",
      saturday_end_time: "00:00",
      sunday_start_time: "00:00",
      sunday_end_time: "00:00"
    }

    staff.each do |name, attributes|
      user = User.create(attributes.except(:athena_id, :athena_department_id, :specialties, :credentials))

      if user.valid?
        if user.has_role? :clinical
          provider_profile = {
            athena_id: attributes[:athena_id],
            athena_department_id: attributes[:athena_department_id],
            provider_id: user.id,
            specialties: attributes[:specialties],
            credentials: attributes[:credentials]
          }
          user.create_provider_profile!(provider_profile)

          default_schedule[:athena_provider_id] = attributes[:athena_id]
          ProviderSchedule.create!(default_schedule)
        end
        print "*"
      else
        print "x"
        puts "Failed to seed staff users - #{user.errors.full_messages}"
        false
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

      #set the primary guardian by time differece
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
                                              sender: conversation.family.primary_parent,
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
