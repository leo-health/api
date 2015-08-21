namespace :load do
  desc "seed staff users"
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
          id: 0,
          title: "Mr",
          first_name: "Super",
          last_name: "User",
          birth_date: 48.years.ago.to_s,
          sex: "M",
          email: "super_user@leohealth.com",
          password: "password",
          password_confirmation: "password",
          role_id: 0,
          avatar_url: "https://elasticbeanstalk-us-east-1-435800161732.s3.amazonaws.com/user/"
      },

      financial: {
          id: 1,
          title: "Mr",
          first_name: "Financial",
          last_name: "User",
          birth_date: 48.years.ago.to_s,
          sex: "M",
          email: "financial_user@leohealth.com",
          password: "password",
          password_confirmation: "password",
          role_id: 1,
          avatar_url: "https://elasticbeanstalk-us-east-1-435800161732.s3.amazonaws.com/user/"
      },

      clinical_support: {
          id: 2,
          title: "Mr",
          first_name: "Clinical_support",
          last_name: "User",
          birth_date: 48.years.ago.to_s,
          sex: "M",
          email: "clinical_support_user@leohealth.com",
          password: "password",
          password_confirmation: "password",
          role_id: 2,
          avatar_url: "https://elasticbeanstalk-us-east-1-435800161732.s3.amazonaws.com/user/"
      },

      customer_service: {
          id: 3,
          title: "Mr",
          first_name: "customer_service",
          last_name: "User",
          birth_date: 48.years.ago.to_s,
          sex: "M",
          email: "customer_service_user@leohealth.com",
          password: "password",
          password_confirmation: "password",
          role_id: 3,
          avatar_url: "https://elasticbeanstalk-us-east-1-435800161732.s3.amazonaws.com/user/"
      },

      clinical: {
          id: 4,
          title: "Mr",
          first_name: "clinical",
          last_name: "User",
          birth_date: 48.years.ago.to_s,
          sex: "M",
          email: "clinical_user@leohealth.com",
          password: "password",
          password_confirmation: "password",
          role_id: 5,
          avatar_url: "https://elasticbeanstalk-us-east-1-435800161732.s3.amazonaws.com/user/"
      }
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
          puts "failed to seed staff users"
          next
        end
      end
    end

    puts "successfully seeded staff users"
  end

  desc "Seed sample guardian users with conversations."
  task :seed_users => :environment do
    (1..10).each do |f|
      family = Family.new

      if family.save
        patient_count = rand(1..6)
        print "f*"
      else
        print "x"
        print "Failed to create a family"
        return false
      end

      guardian_male = family.guardians.create(
        id: 5,
        title: "Mr.",
        first_name: "Pierre",
        middle_initial: "E",
        last_name: "Curie",
        practice_id: 1,
        sex: "M",
        password: "pierrepierre",
        email: "pierre"+family.id.to_s+"@curie.com",
        role: Role.find_or_create_by(id:4, name:"guardian"),
        avatar_url: "https://elasticbeanstalk-us-east-1-435800161732.s3.amazonaws.com/user/"
      )

      if guardian_male.valid?
        print "gm*"
      else
        print "x"
        print "Failed to seed guardian user"
      end

      guardian_female = family.guardians.create(
        id: 6,
        title: "Mrs.",
        first_name: "Marie",
        middle_initial: "S",
        last_name: "Curie",
        practice_id: 1,
        sex: "F",
        password: "mariemarie",
        email: "marie"+family.id.to_s+"@curie.com",
        role: Role.find_or_create_by(id:4, name:"guardian"),
        avatar_url: "https://elasticbeanstalk-us-east-1-435800161732.s3.amazonaws.com/user/"
      )

      if guardian_female.valid?
        print "gf*"
      else
        print "x"
        print "Failed to seed guardian user"
      end

      (0..patient_count).each do |i|
        if patient = family.patients.create(
          title: "",
          first_name: "Eve "+ i.to_s,
          middle_initial: "M.",
          last_name: "Curie",
          sex: "F",
          birth_date: rand(0..21).years.ago,
          role: Role.find_or_create_by(id: 6, name:"patient"),
          avatar_url: "https://elasticbeanstalk-us-east-1-435800161732.s3.amazonaws.com/user/"
        )
          print "p*"
        else
            print "x"
            print "Failed to seed patient user"
        end
      end
      print "\nCreated family #"+ f.to_s + " with " + patient_count.to_s + " children.\n"
    end
  end
end
