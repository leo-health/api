require 'csv'

should_seed_flatiron = ENV['ATHENA_PRACTICE_ID'] == "13092"

# First seed necessary data for all practices

roles_seed = [
  { name: :financial },
  { name: :clinical_support },
  { name: :customer_service },
  { name: :guardian },
  { name: :clinical },
  { name: :bot },
  { name: :operational }
]

roles_seed.each do |param|
  Role.update_or_create!(:name, param)
end

puts "Finished seeding #{roles_seed.count} Role records"

default_provider_schedule = {
  athena_provider_id: nil,
  description: "Default Schedule",
  active: true,
  monday_start_time: "08:00",
  monday_end_time: "19:30",
  tuesday_start_time: "08:00",
  tuesday_end_time: "17:30",
  wednesday_start_time: "10:00",
  wednesday_end_time: "19:30",
  thursday_start_time: "08:00",
  thursday_end_time: "17:30",
  friday_start_time: "09:00",
  friday_end_time: "16:30",
  saturday_start_time: "00:00",
  saturday_end_time: "00:00",
  sunday_start_time: "00:00",
  sunday_end_time: "00:00"
}

AppointmentType.update_or_create!(:name, {
  name: "Other",
  duration: 0,
  hidden: true
})

appointment_statuses_seed = [
  {
    description: "Checked In",
    status: "2"
  },

  {
    description: "Checked Out",
    status: "3"
  },

  {
    description: "Charge Entered",
    status: "4"
  },

  {
    description: "Future",
    status: "f"
  },

  {
    description: "Open",
    status: "o"
  },

  {
    description: "Cancelled",
    status: "x"
  }
]

appointment_statuses_seed.each do |param|
  AppointmentStatus.update_or_create!(:status, param)
end

puts "Finished seeding #{appointment_statuses_seed.count} AppointmentStatus records"

insurance_plan_seed = [
  {
    insurer: {
      insurer_name:"Aetna"
    },

    plans: [
      {id: 1, plan_name: "Choice"},
      {id: 2, plan_name: "Referral"},
      {id: 3, plan_name: "Value Performance"},
      {id: 4, plan_name: "Managed Choice"},
      {id: 5, plan_name: "Select"},
      {id: 6, plan_name: "EPO"},
      {id: 7, plan_name: "Elect"},
      {id: 8, plan_name: "National Advantage"},
      {id: 9, plan_name: "Open Choice"},
      {id: 10, plan_name: "QPOS"},
      {id: 11, plan_name: "Voluntary"},
      {id: 12, plan_name: "PPO"},
      {id: 13, plan_name: "POS"}
    ]
  },

  {
    insurer: {
      insurer_name:"Cigna"
    },

    plans: [
      {id: 14, plan_name: "Network"},
      {id: 15, plan_name: "HMO"},
      {id: 16, plan_name: "Open Access"},
      {id: 17, plan_name: "Choice Fund"},
      {id: 18, plan_name: "POS"},
      {id: 19, plan_name: "PPO"}
    ]
  },


  {
    insurer: {
      insurer_name:"Empire Blue Cross Blue Shield"
    },

    plans: [
      {id: 20, plan_name: "Access"},
      {id: 21, plan_name: "GuidedAccess"},
      {id: 22, plan_name: "HealthPlus"},
      {id: 23, plan_name: "Pathway"},
      {id: 24, plan_name: "Healthy"},
      {id: 25, plan_name: "Hospital"},
      {id: 26, plan_name: "Prism"},
      {id: 27, plan_name: "Indemnity"},
      {id: 28, plan_name: "TotalBlue"},
      {id: 29, plan_name: "Unite Here"},
      {id: 30, plan_name: "HSA"},
      {id: 31, plan_name: "PPO"},
      {id: 32, plan_name: "POS"},
      {id: 33, plan_name: "HMO"},
      {id: 34, plan_name: "EPO"}
    ]
  },

  {
    insurer: {
      insurer_name:"United Healthcare"
    },

    plans: [
      {id: 35, plan_name: "Core"},
      {id: 36, plan_name: "Navigate"},
      {id: 37, plan_name: "Passport Connect"},
      {id: 38, plan_name: "Options"},
      {id: 39, plan_name: "Select"},
      {id: 40, plan_name: "Medica Choice"},
      {id: 41, plan_name: "PacifiCare"},
      {id: 42, plan_name: "PPO"},
      {id: 43, plan_name: "HMO"}
    ]
  },

  {
    insurer: {
      insurer_name:"CareConnect"
    },

    plans: [
      {id: 44, plan_name: "Plan"}
    ]
  },

  {
    insurer: {
      insurer_name:"Other"
    },

    plans: [
      {id: 45, plan_name: "Plan"}
    ]
  }
]

insurance_plan_seed.each do |insurance_plan|
  insurer = Insurer.update_or_create!(:insurer_name, insurance_plan[:insurer])

  insurance_plan[:plans].each do |plan|
    InsurancePlan.update_or_create!(:id, plan.merge(insurer_id: insurer.id))
  end
end

puts "Finished seeding #{insurance_plan_seed.count} InsurancePlan records"

onboarding_group_seed = [
  { group_name: :invited_secondary_guardian }
]

onboarding_group_seed.each do |param|
  OnboardingGroup.update_or_create!(:group_name, param)
end

puts "Finished seeding #{onboarding_group_seed.count} OnboardingGroup records"

#Seed the database with growth curves
begin
  folder = "lib/assets/percentile/oct_2015"
  optionsWho = { col_sep: "\t", headers: true }
  optionsCdc = { headers: true }

  HeightGrowthCurve.delete_all

  #populate boys 0-24 months height
  CSV.foreach("#{folder}/lhfa_boys_p_exp.txt", optionsWho) do |row|
    entry = HeightGrowthCurve.new({ sex: "M", days: row["Day"], l: row["L"], m: row["M"], s: row["S"]})
    entry.save! if (entry.days <= 712)
  end

  #populate girls 0-24 months height
  CSV.foreach("#{folder}/lhfa_girls_p_exp.txt", optionsWho) do |row|
    entry = HeightGrowthCurve.new({ sex: "F", days: row["Day"], l: row["L"], m: row["M"], s: row["S"]})
    entry.save! if (entry.days <= 712)
  end

  #populate boys & girls 2-20 years height
  CSV.foreach("#{folder}/statage.csv", optionsCdc) do |row|
    entry = HeightGrowthCurve.new({
      sex: (row["Sex"] == "1" ? "M" : "F"),
      days: (row["Agemos"].to_i * 365 / 12),
      l: row["L"],
      m: row["M"],
      s: row["S"]})
    entry.save! if (entry.days > 712 && row["Agemos"] != "24")
  end

  puts "Finished seeding HeightGrowthCurve records"

  WeightGrowthCurve.delete_all

  #populate boys 0-24 months weight
  CSV.foreach("#{folder}/wfa_boys_p_exp.txt", optionsWho) do |row|
    entry = WeightGrowthCurve.new({ sex: "M", days: row["Age"], l: row["L"], m: row["M"], s: row["S"]})
    entry.save! if (entry.days <= 712)
  end

  #populate girls 0-24 months weight
  CSV.foreach("#{folder}/wfa_girls_p_exp.txt", optionsWho) do |row|
    entry = WeightGrowthCurve.new({ sex: "F", days: row["Age"], l: row["L"], m: row["M"], s: row["S"]})
    entry.save! if (entry.days <= 712)
  end

  #populate boys & girls 2-20 years weight
  CSV.foreach("#{folder}/wtage.csv", optionsCdc) do |row|
    entry = WeightGrowthCurve.new({
      #Sex==1 for boys, 2 for girls
      :sex=> (row["Sex"] == "1" ? "M" : "F"),
      days: (row["Agemos"].to_i * 365 / 12),
      :l => row["L"],
      :m => row["M"],
      s: row["S"]})
    entry.save! if (entry.days > 712 && row["Agemos"] != "24")
  end

  puts "Finished seeding WeightGrowthCurve records"

  BmiGrowthCurve.delete_all

  #populate boys 0-24 months bmi
  CSV.foreach("#{folder}/bfa_boys_p_exp.txt", optionsWho) do |row|
    entry = BmiGrowthCurve.new({ sex: "M", days: row["Age"], l: row["L"], m: row["M"], s: row["S"]})
    entry.save! if (entry.days <= 712)
  end

  #populate girls 0-24 months bmi
  CSV.foreach("#{folder}/bfa_girls_p_exp.txt", optionsWho) do |row|
    entry = BmiGrowthCurve.new({ sex: "F", days: row["Age"], l: row["L"], m: row["M"], s: row["S"]})
    entry.save! if (entry.days <= 712)
  end

  #populate boys & girls 2-20 years bmi
  CSV.foreach("#{folder}/bmiagerev.csv", optionsCdc) do |row|
    entry = BmiGrowthCurve.new({
      #Sex==1 for boys, 2 for girls
      sex: (row["Sex"] == "1" ? "M" : "F"),
      days: (row["Agemos"].to_i * 365 / 12),
      l: row["L"],
      m: row["M"],
      s: row["S"]})
    entry.save! if (entry.days > 712 && row["Agemos"] != "24")
  end

  puts "Finished seeding BMIGrowthCurve records"
end

if should_seed_flatiron
  Practice.update_or_create!(:athena_id, {
    athena_id: 1,
    name: "Flatiron Pediatrics",
    address_line_1: "27 E 22nd St",
    city: "New York",
    state: "NY",
    zip: "10011",
    phone: "212-460-5600",
    email: "info@leohealth.com",
    time_zone: "Eastern Time (US & Canada)"
  })
else
  Practice.update_or_create!(:athena_id, {
    athena_id: 145,
    name: "Downtown Health Group",
    address_line_1: "8762 Stoneridge Ct",
    city: "North Yarmouth",
    state: "ME",
    zip: "04097",
    phone: "555-482-2453",
    email: "info@leohealth.com",
    time_zone: "Eastern Time (US & Canada)"
  })
end



staff = [{
  first_name: "Leo",
  last_name: "Bot",
  sex: "F",
  email: "leo_bot@leohealth.com",
  password: "password",
  password_confirmation: "password",
  role: Role.find_by(name: :bot),
  practice_id: 1,
  phone: '1234567890',
  avatar_attributes: {
    avatar: Rack::Test::UploadedFile.new(File.join(Rails.root, 'db', 'seed_images', 'Avatar_Bot.png'))
  }
}]
providers = []
appointment_types_seed = []

# Then seed Flatiron specific data if needed
if should_seed_flatiron
  providers += [
    {
      title: "Dr.",
      first_name: "Victoria",
      last_name: "Riese",
      sex: "F",
      email: "victoria@flatironpediatrics.com",
      password: "password",
      password_confirmation: "password",
      role: Role.find_by(name: :clinical),
      practice_id: 1,
      phone: '+19177976816',
      avatar_attributes: {
        avatar: Rack::Test::UploadedFile.new(File.join(Rails.root, 'db', 'seed_images', 'Victoria-Shoulder.png'))
      },

      staff_profile_attributes: {
        specialties: "",
        credentials: ["MD"]
      },

      provider_attributes: {
        athena_id: 1,
        athena_department_id: 1
      },

      provider_schedule_attributes: { athena_provider_id: 1 }.reverse_merge(default_provider_schedule)
    },

    {
      first_name: "Erin",
      last_name: "Gold",
      sex: "F",
      email: "erin@flatironpediatrics.com",
      password: "password",
      password_confirmation: "password",
      role: Role.find_by(name: :clinical),
      practice_id: 1,
      phone: '+16177912619',
      staff_profile_attributes: {
        specialties: "",
        credentials: ["NP"]
      },

      avatar_attributes: {
        avatar: Rack::Test::UploadedFile.new(File.join(Rails.root, 'db', 'seed_images', 'Erin-Shoulder.png'))
      },

      provider_attributes: {
        athena_id: 3,
        athena_department_id: 1
      },

      provider_schedule_attributes: { athena_provider_id: 3 }.reverse_merge(default_provider_schedule)
    }
  ]

  staff += [
    {
      first_name: "Marcey",
      last_name: "Brody",
      sex: "F",
      email: "marcey@flatironpediatrics.com",
      password: "password",
      password_confirmation: "password",
      role: Role.find_by(name: :clinical_support),
      practice_id: 1,
      phone: '+16302122713',
      staff_profile_attributes: {
        specialties: "",
        credentials: ["RN"]
      },
      avatar_attributes: {
        avatar: Rack::Test::UploadedFile.new(File.join(Rails.root, 'db', 'seed_images', 'Marcey-Shoulder.png'))
      }
    },

    {
      first_name: "Catherine",
      last_name: "Franco",
      sex: "F",
      email: "catherine@flatironpediatrics.com",
      password: "password",
      password_confirmation: "password",
      role: Role.find_by(name: :customer_service),
      practice_id: 1,
      phone: '+19176929777',
      staff_profile_attributes: {
        specialties: "",
        credentials: ["Office Manager"]
      },
      avatar_attributes: {
        avatar: Rack::Test::UploadedFile.new(File.join(Rails.root, 'db', 'seed_images', 'Catherine-Shoulder.png'))
      }
    },

    {
      first_name: "Kristen",
      last_name: "Castellano",
      sex: "F",
      email: "kristen@flatironpediatrics.com",
      password: "password",
      password_confirmation: "password",
      role: Role.find_by(name: :financial),
      practice_id: 1,
      phone: '+19736327321',
      staff_profile_attributes: {
        specialties: "",
        credentials: ["RN"]
      },
      avatar_attributes: {
        avatar: Rack::Test::UploadedFile.new(File.join(Rails.root, 'db', 'seed_images', 'Kristen-Shoulder.png'))
      }
    },

    {
      first_name: "Ben",
      last_name: "Siscovick",
      sex: "M",
      email: "b@leohealth.com",
      password: "password",
      password_confirmation: "password",
      role: Role.find_by(name: :customer_service),
      practice_id: 1,
      phone: '+12068198549',
      avatar_attributes: {
        avatar: Rack::Test::UploadedFile.new(File.join(Rails.root, 'db', 'seed_images', 'Avatar_Bot.png'))
      }
    },

    {
      first_name: "Zach",
      last_name: "Drossman",
      sex: "M",
      email: "z@leohealth.com",
      password: "password",
      password_confirmation: "password",
      role: Role.find_by(name: :customer_service),
      practice_id: 1,
      phone: '+12672559107',
      avatar_attributes: {
        avatar: Rack::Test::UploadedFile.new(File.join(Rails.root, 'db', 'seed_images', 'Avatar_Bot.png'))
      }
    },

    {
      first_name: "Jackie",
      last_name: "McNamara",
      sex: "F",
      email: "j@leohealth.com",
      password: "password",
      password_confirmation: "password",
      role: Role.find_by(name: :customer_service),
      practice_id: 1,
      phone: '+17819645918',
      avatar_attributes: {
        avatar: Rack::Test::UploadedFile.new(File.join(Rails.root, 'db', 'seed_images', 'Avatar_Bot.png'))
      }
    },

    {
      first_name: "Nayan",
      last_name: "Jain",
      sex: "M",
      email: "n@leohealth.com",
      password: "password",
      password_confirmation: "password",
      role: Role.find_by(name: :customer_service),
      practice_id: 1,
      phone: '+12035223374',
      avatar_attributes: {
        avatar: Rack::Test::UploadedFile.new(File.join(Rails.root, 'db', 'seed_images', 'Avatar_Bot.png'))
      }
    },

    {
      first_name: "Lydia",
      last_name: "Zolman",
      sex: "F",
      email: "l@leohealth.com",
      password: "password",
      password_confirmation: "password",
      role: Role.find_by(name: :customer_service),
      practice_id: 1,
      phone: '+17038879869',
      avatar_attributes: {
        avatar: Rack::Test::UploadedFile.new(File.join(Rails.root, 'db', 'seed_images', 'Avatar_Bot.png'))
      }
    }
  ]

  appointment_types_seed += [
    {
      athena_id: 10,
      name: "Sick Visit",
      duration: 10,
      short_description: "New symptom",
      long_description: "A visit to address new symptoms like cough, cold, ear pain, fever, diarrhea, or rash.",
      hidden: false
    },

    {
      athena_id: 12,
      name: "Follow Up Visit",
      duration: 10,
      short_description: "Unresolved illness or chronic condition",
      long_description: "A visit to follow up on a known condition like asthma, ADHD, or eczema.",
      hidden: false
    },

    {
      athena_id: 8,
      name: "Immunization / Lab Visit",
      duration: 10,
      short_description: "Flu shot or scheduled vaccine",
      long_description: "A visit with a nurse to get one or more immunizations.",
      hidden: false
    },

    {
      athena_id: 11,
      name: "Well Visit",
      duration: 20,
      short_description: "Regular check-up",
      long_description: "A regular check-up that is typically scheduled every few months up until age 2 and annually thereafter.",
      hidden: false
    },

    {
      athena_id: 22,
      name: "Consult",
      duration: 30,
      short_description: "First visit to the practice",
      long_description: "A first visit with the provider and the staff to learn more about the practice",
      hidden: true
    },

    {
      athena_id: 14,
      name: "Block",
      duration: 10,
      short_description: "Block",
      long_description: "Block",
      hidden: true
    }
  ]
end


def person_attributes(person)
  Person.writable_column_names.reduce({}) { |memo, col| memo[col] = person.send(col); memo }
end

providers.each do |attributes|
  if user = User.find_by(email: attributes[:email])
    user.update_attributes!(attributes.except(:password, :password_confirmation, :provider_schedule_attributes, :provider_attributes, :staff_profile_attributes, :avatar_attributes))
  else
    user = User.create!(attributes.except(:avatar_attributes, :provider_schedule_attributes))
    Delayed::Job.where(queue: "registration_email").order("created_at DESC").first.destroy if Rails.env.development?
  end

  if avatar = user.avatar
    avatar.update_attributes!(attributes[:avatar_attributes])
  else
    begin
      Avatar.create!(attributes[:avatar_attributes].merge(owner: user))
    rescue Seahorse::Client::NetworkingError => e
      puts "Could not create Avatar: #{e}"
    end
  end

  if attributes[:staff_profile_attributes] && user.staff_profile
    user.staff_profile.update_attributes!(person_attributes(user).merge(attributes[:staff_profile_attributes]))
  end

  if attributes[:provider_attributes] && user.provider
    user.provider.update_attributes!(person_attributes(user).merge(attributes[:provider_attributes]))
  end

  if attributes[:provider_schedule_attributes]
    if provider_schedule = ProviderSchedule.find_by(athena_provider_id: user.provider.try(:athena_id))
      provider_schedule.update_attributes!(attributes[:provider_schedule_attributes])
    else
      ProviderSchedule.create!(attributes[:provider_schedule_attributes])
    end
  end
end

puts "Finished seeding #{providers.count} User & Provider & ProviderSchedule records"

staff.each do |attributes|
  if user = User.find_by(email: attributes[:email])
    user.update_attributes!(attributes.except(:password, :password_confirmation, :avatar_attributes, :staff_profile_attributes))
  else
    user = User.create!(attributes.except(:avatar_attributes))
    Delayed::Job.where(queue: "registration_email").order("created_at DESC").first.destroy if Rails.env.development?
  end

  if avatar = user.avatar
    avatar.update_attributes!(attributes[:avatar_attributes])
  else
    begin
      Avatar.create!(attributes[:avatar_attributes].merge(owner: user))
    rescue Seahorse::Client::NetworkingError => e
      puts "Could not create Avatar: #{e}"
    end
  end

  if attributes[:staff_profile_attributes] && user.staff_profile
    user.staff_profile.update_attributes!(person_attributes(user).merge(attributes[:staff_profile_attributes]))
  end
end

puts "Finished seeding #{staff.count} User & StaffProfile records"

appointment_types_seed.each do |param|
  AppointmentType.update_or_create!(:name, param)
end

puts "Finished seeding #{appointment_types_seed.count} AppointmentType records"

default_practice_schedule = {
  practice_id: 1,
  monday_start_time: "08:00",
  monday_end_time: "19:30",
  tuesday_start_time: "08:00",
  tuesday_end_time: "17:30",
  wednesday_start_time: "10:00",
  wednesday_end_time: "19:30",
  thursday_start_time: "08:00",
  thursday_end_time: "17:30",
  friday_start_time: "09:00",
  friday_end_time: "16:30",
  saturday_start_time: "00:00",
  saturday_end_time: "00:00",
  sunday_start_time: "00:00",
  sunday_end_time: "00:00"
}

practice_schedules = [
  {
    id: 1,
    schedule_type: :default,
    active: true
  }.reverse_merge(default_practice_schedule),

  {
    id: 2,
    schedule_type: :emergency,
    active: false
  }.reverse_merge(default_practice_schedule),

  {
    id: 3,
    schedule_type: :holiday,
    active: false
  }.reverse_merge(default_practice_schedule)
]

practice_schedules.each do |params|
  PracticeSchedule.update_or_create!(:id, params)
end

puts "Finished seeding #{practice_schedules.count} PracticeSchedule records"

practice_holidays = [
  "01/01/2016", #New Year's Day
  "05/30/2016", #Memorial Day
  "07/04/2016", #Independence Day
  "09/05/2016", #Labor Day
  "11/24/2016", #Thanksgiving
  "12/25/2016"  #Christmas
]

ProviderLeave.where(athena_id: 0).delete_all

Provider.all.each do |provider|
  practice_holidays.each do | holiday |
    ProviderLeave.create(
      athena_id: 0,
      athena_provider_id: provider.athena_id,
      description: "Seeded holiday",
      start_datetime: AthenaHealthApiHelper.to_datetime(holiday, "00:00"),
      end_datetime: AthenaHealthApiHelper.to_datetime(holiday, "00:00") + 24.hours
    )
  end
end

puts "Finished seeding #{ProviderLeave.count} ProviderLeave records"

puts "Finished seeding all data"
