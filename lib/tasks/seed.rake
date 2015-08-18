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
        birth_date: 48.years.ago.to_s,
        sex: "M",
        email: "super_user@leohealth.com",
        password: "password",
        password_confirmation: "password"
    },

    financial: {
        title: "Mr",
        first_name: "Financial",
        last_name: "User",
        birth_date: 48.years.ago.to_s,
        sex: "M",
        email: "financial_user@leohealth.com",
        password: "password",
        password_confirmation: "password"
    },

    clinical_support: {
        title: "Mr",
        first_name: "Clinical_support",
        last_name: "User",
        birth_date: 48.years.ago.to_s,
        sex: "M",
        email: "clinical_support_user@leohealth.com",
        password: "password",
        password_confirmation: "password"
    },

    customer_service: {
        title: "Mr",
        first_name: "customer_service",
        last_name: "User",
        birth_date: 48.years.ago.to_s,
        sex: "M",
        email: "customer_service_user@leohealth.com",
        password: "password",
        password_confirmation: "password"
    },

    clinical: {
        title: "Mr",
        first_name: "clinical",
        last_name: "User",
        birth_date: 48.years.ago.to_s,
        sex: "M",
        email: "clinical_user@leohealth.com",
        password: "password",
        password_confirmation: "password"
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
        user.add_role name
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
