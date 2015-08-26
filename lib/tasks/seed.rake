
namespace :load do

  desc 'Seed test data'
  task all: :environment do
    begin
      ["load:seed_staff", "load:seed_guardians"].each do |t|
        Rake::Task[t].execute
        puts "#{t} completed".green
      end
    end
  end

  desc "Seed the database with staff users"
  task seed_staff: :environment do

    staff = {
      super_user: {
          title: "Mr",
          first_name: "Super",
          last_name: "User",
          birth_date: 48.years.ago.to_s,
          sex: "M",
          email: "super_user@leohealth.com",
          password: "password",
          password_confirmation: "password",
          role_id: 0,
          practice_id: 0,
          avatar_url: "https://elasticbeanstalk-us-east-1-435800161732.s3.amazonaws.com/user/"
      },

      financial: {
          title: "Mr",
          first_name: "Financial",
          last_name: "User",
          birth_date: 48.years.ago.to_s,
          sex: "M",
          email: "financial_user@leohealth.com",
          password: "password",
          password_confirmation: "password",
          role_id: 1,
          practice_id: 0,
          avatar_url: "https://elasticbeanstalk-us-east-1-435800161732.s3.amazonaws.com/user/"
      },

      clinical_support: {
          title: "Mr",
          first_name: "Clinical_support",
          last_name: "User",
          birth_date: 48.years.ago.to_s,
          sex: "M",
          email: "clinical_support_user@leohealth.com",
          password: "password",
          password_confirmation: "password",
          role_id: 2,
          practice_id: 0,
          avatar_url: "https://elasticbeanstalk-us-east-1-435800161732.s3.amazonaws.com/user/"
      },

      customer_service: {
          title: "Mr",
          first_name: "customer_service",
          last_name: "User",
          birth_date: 48.years.ago.to_s,
          sex: "M",
          email: "customer_service_user@leohealth.com",
          password: "password",
          password_confirmation: "password",
          role_id: 3,
          practice_id: 0,
          avatar_url: "https://elasticbeanstalk-us-east-1-435800161732.s3.amazonaws.com/user/"
      },

      clinical: {
          title: "Mr",
          first_name: "clinical",
          last_name: "User",
          birth_date: 48.years.ago.to_s,
          sex: "M",
          email: "clinical_user@leohealth.com",
          password: "password",
          password_confirmation: "password",
          role_id: 5,
          practice_id: 0,
          avatar_url: "https://elasticbeanstalk-us-east-1-435800161732.s3.amazonaws.com/user/"
      }
    }

    provider_profiles = [{
      specialties: "",
      credentials: ""
    }]

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
      user = User.create(attributes)

      if user.valid?
        if user.has_role? :clinical
          provider_profiles[0][:provider_id] = user.id
          user.create_provider_profile!(provider_profiles[0])
          ProviderSchedule.create!(default_schedule)
        end
        print "*".green
      else
        print "/"
        puts " failed to seed staff users. - #{user.errors.full_messages}".red
        false
      end
    end
    puts " successfully seeded staff users".green
  end




  desc "Seed sample guardian users with conversations."
  task seed_guardians: :environment do
    (0..4).each do |f|
      family = Family.new

      if family.save
        print "f*".green
      else
        print "x".red
        print "Failed to create a family".red
        false
      end

      guardian_male = family.guardians.create!(
        title: "Mr.",
        first_name: "Pierre",
        middle_initial: "E",
        last_name: "Curie",
        sex: "M",
        password: "pierrepierre",
        email: "pierre"+family.id.to_s+"@curie.com",
        role_id: 4,
        practice_id: 0,
        avatar_url: "https://elasticbeanstalk-us-east-1-435800161732.s3.amazonaws.com/user/"
      )

      if guardian_male.valid?
        print "gm*".green
      else
        print "x".red
        print "Failed to seed guardian user".red
        false
      end

      guardian_female = family.guardians.create!(
        title: "Mrs.",
        first_name: "Marie",
        middle_initial: "S",
        last_name: "Curie",
        sex: "F",
        password: "mariemarie",
        email: "marie"+family.id.to_s+"@curie.com",
        role_id: 4,
        practice_id: 0,
        avatar_url: "https://elasticbeanstalk-us-east-1-435800161732.s3.amazonaws.com/user/"
      )

      if guardian_female.valid?
        print "gf*".green
      else
        print "x".red
        print "Failed to seed guardian user".red
        false
      end

      if f > 0
        (1..f).each do |i|
          if patient = family.patients.create!(
            title: "",
            first_name: "Eve "+ i.to_s,
            middle_initial: "M.",
            last_name: "Curie",
            sex: "F",
            birth_date: i.years.ago,
            role_id: 6,
            avatar_url: "https://elasticbeanstalk-us-east-1-435800161732.s3.amazonaws.com/user/"
          )
            print "p*".green
          else
            print "x".red
            print "Failed to seed patient user".red
            false
          end
        end
      end
      puts "Created family #{f.to_s} with #{f.to_s} children.".green
    end
  end
end
