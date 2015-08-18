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
          title: "Mr",
          first_name: "Super",
          last_name: "User",
          dob: 48.years.ago.to_s,
          sex: "M",
          email: "super_user@leohealth.com",
          password: "password",
          password_confirmation: "password",
          role_id: 0
      },

      financial: {
          title: "Mr",
          first_name: "Financial",
          last_name: "User",
          dob: 48.years.ago.to_s,
          sex: "M",
          email: "financial_user@leohealth.com",
          password: "password",
          password_confirmation: "password",
          role_id: 1
      },

      clinical_support: {
          title: "Mr",
          first_name: "Clinical_support",
          last_name: "User",
          dob: 48.years.ago.to_s,
          sex: "M",
          email: "clinical_support_user@leohealth.com",
          password: "password",
          password_confirmation: "password",
          role_id: 2
      },

      customer_service: {
          title: "Mr",
          first_name: "customer_service",
          last_name: "User",
          dob: 48.years.ago.to_s,
          sex: "M",
          email: "customer_service_user@leohealth.com",
          password: "password",
          password_confirmation: "password",
          role_id: 3
      },

      clinical: {
          title: "Mr",
          first_name: "clinical",
          last_name: "User",
          dob: 48.years.ago.to_s,
          sex: "M",
          email: "clinical_user@leohealth.com",
          password: "password",
          password_confirmation: "password",
          role_id: 5
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

    for f in 1..10
      if family = Family.new
        family.save
        patient_count = rand(1..6)
        print "f*"
      else
        print "x"
        print "Failed to create a family"
      end

      if guardian_male = User.create(
        title: "Mr.",
        first_name: "Pierre",
        middle_initial: "E",
        last_name: "Curie",
        practice_id: 1,
        sex: "M",
        password: "pierrepierre",
        email: "pierre"+family.id.to_s+"@curie.com",
        family_id: family.id,
        role: Role.find_or_create_by(id:4, name:"guardian")
      )

        guardian_male.confirm
        print "gm*"
      else
        print "x"
        print "Failed to seed guardian user"
      end

      if guardian_female = User.create(
        title: "Mrs.",
        first_name: "Marie",
        middle_initial: "S",
        last_name: "Curie",
        practice_id: 1,
        sex: "F",
        password: "mariemarie",
        email: "marie"+family.id.to_s+"@curie.com",
        family_id: family.id,
        role: Role.find_or_create_by(id:4, name:"guardian")
      )

        guardian_female.confirm
        print "gf*"
      else
        print "x"
        print "Failed to seed guardian user"
      end

      for i in 0..patient_count
        if patient = Patient.create(
          title: "",
          first_name: "Eve",
          middle_initial: i.to_s,
          last_name: "Curie",
          sex: "F",
          birth_date: rand(0..21).years.ago,
          family_id: family.id,
          role: Role.find_or_create_by(id: 6, name:"patient")
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
