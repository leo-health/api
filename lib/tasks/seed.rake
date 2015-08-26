namespace :load do

  desc "Seed the database with staff users"
  task :seed_staff => :environment do
    roles = {
        super_user: 0,
        financial: 1,
        clinical_support: 2,
        customer_service: 3,
        clinical: 5
    }

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
      provider_id: 1,
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

    roles.each do |name, id|
      Role.update_or_create_by_id_and_name(id, name) do |r|
        r.save
      end
    end

    staff.each do |name, attributes|
      if user = User.find_by_email(attributes[:email])
        user.has_role? name ? (print "*") : (user.add_role name)
      else
        if user = User.create(attributes)
          user.confirm
          print "*"
        else
          print "/"
          puts " failed to seed staff users."
          next
        end
      end
    end

    provider_profiles.each do |attributes|
      ProviderProfile.create_with(attributes).find_or_create_by(provider_id: attributes[:provider_id])
      ProviderSchedule.create_with(default_schedule).find_or_create_by(athena_provider_id: attributes[:provider_id])
    end

    puts " successfully seeded staff users"
  end

  desc "Seed sample guardian users with conversations."
  task :seed_guardians => :environment do
    (0..4).each do |f|
      family = Family.new

      if family.save
        print "f*"
      else
        print "x"
        print "Failed to create a family"
        return false
      end

      guardian_male = family.guardians.create(
        title: "Mr.",
        first_name: "Pierre",
        middle_initial: "E",
        last_name: "Curie",
        sex: "M",
        password: "pierrepierre",
        email: "pierre"+family.id.to_s+"@curie.com",
        role: Role.find_or_create_by(id:4, name:"guardian"),
        practice_id: 0,
        avatar_url: "https://elasticbeanstalk-us-east-1-435800161732.s3.amazonaws.com/user/"
      )
      if guardian_male.valid?
        print "gm*"
      else
        print "x"
        print "Failed to seed guardian user"
      end

      guardian_female = family.guardians.create!(
        title: "Mrs.",
        first_name: "Marie",
        middle_initial: "S",
        last_name: "Curie",
        sex: "F",
        password: "mariemarie",
        email: "marie"+family.id.to_s+"@curie.com",
        role: Role.find_or_create_by(id:4, name:"guardian"),
        practice_id: 0,
        avatar_url: "https://elasticbeanstalk-us-east-1-435800161732.s3.amazonaws.com/user/"
      )

      if guardian_female.valid?
        print "gf*"
      else
        print "x"
        print "Failed to seed guardian user"
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
            role: Role.find_or_create_by(id: 6, name:"patient"),
            avatar_url: "https://elasticbeanstalk-us-east-1-435800161732.s3.amazonaws.com/user/"
          )
            print "p*"
          else
            print "x"
            print "Failed to seed patient user"
          end
        end
      end
      print "\nCreated family #"+ f.to_s + " with " + f.to_s + " children.\n"
    end
  end
end
