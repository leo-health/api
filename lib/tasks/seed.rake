require 'csv'

namespace :load do

  desc 'Seed test data'
  task all: :environment do
    begin
      ["load:seed_staff", "load:seed_guardians", "load:seed_growth_curves"].each do |t|
        Rake::Task[t].execute
        puts "#{t} completed"
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
          phone_number: '1234567890',
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
          phone_number: '1234567890',
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
          phone_number: '1234567890',
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
          phone_number: '1234567890',
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
          avatar_url: "https://elasticbeanstalk-us-east-1-435800161732.s3.amazonaws.com/user/",
          athena_id: 1,
          athena_department_id: 1,
          specialties: "",
          phone_number: '1234567890',
          credentials: ""
      },

      hgold: {
          title: "Mrs",
          first_name: "Erin",
          last_name: "Gold",
          birth_date: 48.years.ago.to_s,
          sex: "F",
          email: "hgold@leohealth.com",
          password: "password",
          password_confirmation: "password",
          role_id: 5,
          practice_id: 0,
          avatar_url: "https://elasticbeanstalk-us-east-1-435800161732.s3.amazonaws.com/user/",
          athena_id: 3,
          athena_department_id: 2,
          specialties: "",
          phone_number: '1234567890',
          credentials: ""
      },

      vriese: {
          title: "Mrs",
          first_name: "Victoria",
          last_name: "Riese",
          birth_date: 48.years.ago.to_s,
          sex: "F",
          email: "victoria@leohealth.com",
          password: "password",
          password_confirmation: "password",
          role_id: 5,
          practice_id: 0,
          avatar_url: "https://elasticbeanstalk-us-east-1-435800161732.s3.amazonaws.com/user/",
          athena_id: 4,
          athena_department_id: 2,
          specialties: "",
          phone_number: '1234567890',
          credentials: ""
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
    (0..4).each do |f|
      family = Family.new

      if family.save
        print "*"
      else
        print "x"
        print "Failed to create a family - #{family.errors.full_messages}"
        false
      end

      guardian_male = family.guardians.create!(
        title: "Mr.",
        first_name: "Pierre",
        middle_initial: "E",
        last_name: "Curie",
        sex: "M",
        password: "pierrepierre",
        email: "pierre#{family.id.to_s}@curie.com",
        role_id: 4,
        practice_id: 0,
        phone_number: '1234567890',
        avatar_url: "https://elasticbeanstalk-us-east-1-435800161732.s3.amazonaws.com/user/"
      )

      if guardian_male.valid?
        print "*"
      else
        print "x"
        print "Failed to seed guardian user - #{guardian_male.errors.full_messages}"
        false
      end

      guardian_female = family.guardians.create!(
        title: "Mrs.",
        first_name: "Marie",
        middle_initial: "S",
        last_name: "Curie",
        sex: "F",
        password: "mariemarie",
        email: "marie#{family.id.to_s}@curie.com",
        role_id: 4,
        practice_id: 0,
        phone_number: '1234567890',
        avatar_url: "https://elasticbeanstalk-us-east-1-435800161732.s3.amazonaws.com/user/"
      )

      if guardian_female.valid?
        print "*"
      else
        print "x"
        print "Failed to seed guardian user - #{guardian_female.errors.full_messages}"
        false
      end

      if f > 0
        (1..f).each do |i|
          if patient = family.patients.create!(
            title: "",
            first_name: "Eve #{i.to_s}",
            middle_initial: "M.",
            last_name: "Curie",
            sex: "F",
            birth_date: i.years.ago,
            role_id: 6,
            avatar_url: "https://elasticbeanstalk-us-east-1-435800161732.s3.amazonaws.com/user/"
          )
            print "*"
          else
            print "x"
            print "Failed to seed patient user - #{patient.errors.full_messages}"
            false
          end
        end
      end
      puts "Created family #{family.id.to_s} with #{family.patients.count+1} children."
    end
  end

  desc "Seed the database with growth curves"
  task seed_growth_curves: :environment do
    optionsWho = { :col_sep => "\t", :headers => true }
    optionsCdc = { :headers => true }

    HeightGrowthCurve.delete_all

    #populate boys 0-24 months height
    CSV.foreach("lib/assets/percentile/lhfa_boys_p_exp.txt", optionsWho) do |row|
      entry = HeightGrowthCurve.new({ :sex=> "M", :days => row["Day"], :l => row["L"], :m => row["M"], :s => row["S"]})
      entry.save if (entry.days <= 712)
    end

    #populate girls 0-24 months height
    CSV.foreach("lib/assets/percentile/lhfa_girls_p_exp.txt", optionsWho) do |row|
      entry = HeightGrowthCurve.new({ :sex=> "F", :days => row["Day"], :l => row["L"], :m => row["M"], :s => row["S"]})
      entry.save if (entry.days <= 712)
    end

    #populate boys & girls 2-20 years height
    CSV.foreach("lib/assets/percentile/statage.csv", optionsCdc) do |row|
      entry = HeightGrowthCurve.new({ 
        :sex=> (row["Sex"] == "1" ? "M" : "F"), 
        :days => (row["Agemos"].to_i * 365 / 12), 
        :l => row["L"], 
        :m => row["M"], 
        :s => row["S"]})
      entry.save if (entry.days > 712 && row["Agemos"] != "24")
    end

    WeightGrowthCurve.delete_all

    #populate boys 0-24 months weight
    CSV.foreach("lib/assets/percentile/wfa_boys_p_exp.txt", optionsWho) do |row|
      entry = WeightGrowthCurve.new({ :sex=> "M", :days => row["Age"], :l => row["L"], :m => row["M"], :s => row["S"]})
      entry.save if (entry.days <= 712)
    end

    #populate girls 0-24 months weight
    CSV.foreach("lib/assets/percentile/wfa_girls_p_exp.txt", optionsWho) do |row|
      entry = WeightGrowthCurve.new({ :sex=> "F", :days => row["Age"], :l => row["L"], :m => row["M"], :s => row["S"]})
      entry.save if (entry.days <= 712)
    end

    #populate boys & girls 2-20 years weight
    CSV.foreach("lib/assets/percentile/wtage.csv", optionsCdc) do |row|
      entry = WeightGrowthCurve.new({ 
        :sex=> (row["Sex"] == "1" ? "M" : "F"), 
        :days => (row["Agemos"].to_i * 365 / 12), 
        :l => row["L"], 
        :m => row["M"], 
        :s => row["S"]})
      entry.save if (entry.days > 712 && row["Agemos"] != "24")
    end
  end
end
