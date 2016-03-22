require 'csv'

practices_seed = [
    {
        id: 1,
        athena_id: 1,
        name: "Flatiron Pediatrics",
        address_line_1: "27 E 22nd St",
        address_line_2: "",
        city: "New York",
        state: "NY",
        zip: "10011",
        fax: "",
        phone: "212-460-5600",
        email: "info@leohealth.com",
        time_zone: "Eastern Time (US & Canada)"
    }
]

practices_seed.each do |param|
  if practice = Practice.find_by(id: param[:id])
    practice.update_attributes!(param)
  else
    Practice.create!(param)
  end
end

roles_seed = {
          # Access accounting and billing data for administrative staff
          financial: 1,
          # Access to clinical data for non-provider roles including a nurse practicioner, medical asssitant, or nurse
          clinical_support: 2,
          # Access to service level data to provide support for non-clinical issues and feedback
          customer_service: 3,
          # Access to user their data and shared data where relationships are maintained
          guardian: 4,
          # Access to clinical data for provider roles and other (sub)specialists
          clinical: 5,
          # Access to all data pertaining to the patient
          patient: 6,
          # bot user
          bot: 7,
          operational: 8
        }

roles_seed.each do |role, id|
  Role.update_or_create_by_id_and_name(id, role) do |r|
    r.save!
  end
end

staff = [
  {
    first_name: "Leo",
    last_name: "Bot",
    sex: "F",
    email: "leo_bot@leohealth.com",
    password: "password",
    password_confirmation: "password",
    role_id: 7,
    practice_id: 1,
    phone: '1234567890',
    avatar_attributes: {
      avatar: Rack::Test::UploadedFile.new(File.join(Rails.root, 'db', 'seed_images', 'Avatar_Guardian_Mom.png'))
    }
  },

  {
    title: "Dr.",
    first_name: "Victoria",
    last_name: "Riese",
    sex: "F",
    email: "victoria@flatironpediatrics.com",
    password: "password",
    password_confirmation: "password",
    role_id: 5,
    practice_id: 1,
    phone: '+19177976816',
    avatar_attributes: {
      avatar: Rack::Test::UploadedFile.new(File.join(Rails.root, 'db', 'seed_images', 'Victoria-Shoulder.png'))
    },

    staff_profile_attributes: {
      specialties: "",
      credentials: ["MD"]
    },

    provider_sync_profile_attributes: {
      athena_id: 1,
      athena_department_id: 1
    },

    provider_schedule_attributes: {
      athena_provider_id: 1,
      description: "Default Schedule",
      active: true,
      monday_start_time: "08:00",
      monday_end_time: "11:00",
      tuesday_start_time: "08:00",
      tuesday_end_time: "18:00",
      wednesday_start_time: "10:00",
      wednesday_end_time: "19:20",
      thursday_start_time: "08:00",
      thursday_end_time: "13:00",
      friday_start_time: "09:00",
      friday_end_time: "18:00",
      saturday_start_time: "10:00",
      saturday_end_time: "14:00",
      sunday_start_time: "00:00",
      sunday_end_time: "00:00"
    }
  },

  {
    first_name: "Erin",
    last_name: "Gold",
    sex: "F",
    email: "erin@flatironpediatrics.com",
    password: "password",
    password_confirmation: "password",
    role_id: 5,
    practice_id: 1,
    phone: '+16177912619',
    staff_profile_attributes: {
      specialties: "",
      credentials: ["NP"]
    },

    avatar_attributes: {
      avatar: Rack::Test::UploadedFile.new(File.join(Rails.root, 'db', 'seed_images', 'Erin-Shoulder.png'))
    },

    provider_sync_profile_attributes: {
      athena_id: 3,
      athena_department_id: 1
    },

    provider_schedule_attributes: {
      athena_provider_id: 3,
      description: "Default Schedule",
      active: true,
      monday_start_time: "11:00",
      monday_end_time: "19:20",
      tuesday_start_time: "08:00",
      tuesday_end_time: "18:00",
      wednesday_start_time: "00:00",
      wednesday_end_time: "00:00",
      thursday_start_time: "14:00",
      thursday_end_time: "18:00",
      friday_start_time: "09:00",
      friday_end_time: "17:00",
      saturday_start_time: "10:00",
      saturday_end_time: "14:00",
      sunday_start_time: "00:00",
      sunday_end_time: "00:00"
    }
  },

  {
    first_name: "Marcey",
    last_name: "Brody",
    sex: "F",
    email: "marcey@flatironpediatrics.com",
    password: "password",
    password_confirmation: "password",
    role_id: 2,
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
    role_id: 3,
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
    role_id: 1,
    practice_id: 1,
    phone: '+19736327321',
    staff_profile_attributes: {
      specialties: "",
      credentials: ["RN"]
    },

    avatar_attributes: {
      avatar: Rack::Test::UploadedFile.new(File.join(Rails.root, 'db', 'seed_images', 'Kristen-Shoulder.png'))
    }
  }
]

staff.each do |attributes|
  if user = User.find_by(email: attributes[:email])
    user.update_attributes!(attributes.except(:password, :password_confirmation, :provider_schedule_attributes, :provider_sync_profile_attributes, :staff_profile_attributes, :avatar_attributes))
  else
    user = User.create!(attributes.except(:avatar_attributes, :staff_profile_attributes, :provider_sync_profile_attributes, :provider_schedule_attributes))
  end

  if avatar = user.avatar
    avatar.update_attributes!(attributes[:avatar_attributes])
  else
    Avatar.create!(attributes[:avatar_attributes].merge(owner: user))
  end

  if attributes[:staff_profile_attributes]
    if staff_profile = user.staff_profile
      staff_profile.update_attributes!(attributes[:staff_profile_attributes])
    else
      StaffProfile.create!(attributes[:staff_profile_attributes].merge(staff: user))
    end
  end

  if attributes[:provider_sync_profile_attributes]
    if provider_sync_profile = user.provider_sync_profile
      provider_sync_profile.update_attributes!(attributes[:provider_sync_profile_attributes])
    else
      ProviderSyncProfile.create!(attributes[:provider_sync_profile_attributes].merge(provider: user))
    end
  end

  if attributes[:provider_schedule_attributes]
    if athena_id = user.provider_sync_profile.try(:athena_id)
      provider_schedule = ProviderSchedule.find_by(athena_provider_id: athena_id)
      provider_schedule.update_attributes!(attributes[:provider_schedule_attributes])
    else
      ProviderSchedule.create!(attributes[:provider_schedule_attributes])
    end
  end
end

team = [
  {
    first_name: "Ben",
    last_name: "Siscovick",
    sex: "M",
    email: "b@leohealth.com",
    password: "password",
    password_confirmation: "password",
    role_id: 3,
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
    role_id: 3,
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
    role_id: 3,
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
    role_id: 3,
    practice_id: 1,
    phone: '+12035223374',
    avatar_attributes: {
      avatar: Rack::Test::UploadedFile.new(File.join(Rails.root, 'db', 'seed_images', 'Avatar_Bot.png'))
    }
  }
]

team.each do |attributes|
  if user = User.find_by(email: attributes[:email])
    user.update_attributes!(attributes.except(:password, :password_confirmation, :avatar_attributes))
  else
    user = User.create!(attributes.except(:avatar_attributes))
  end

  if avatar = user.avatar
    avatar.update_attributes!(attributes[:avatar_attributes].merge(owner: user))
  else
    Avatar.create!(attributes[:avatar_attributes].merge(owner: user))
  end
end

appointment_types_seed = [
  {
    id: 1,
    athena_id: 10,
    name: "Sick Visit",
    duration: 10,
    short_description: "New symptom",
    long_description: "A visit to address new symptoms like cough, cold, ear pain, fever, diarrhea, or rash.",
    hidden: false
  },

  {
    id: 2,
    athena_id: 12,
    name: "Follow Up Visit",
    duration: 10,
    short_description: "Unresolved illness or chronic condition",
    long_description: "A visit to follow up on a known condition like asthma, ADHD, or eczema.",
    hidden: false
  },

  {
    id: 3,
    athena_id: 8,
    name: "Immunization / Lab Visit",
    duration: 10,
    short_description: "Flu shot or scheduled vaccine",
    long_description: "A visit with a nurse to get one or more immunizations.",
    hidden: false
  },

  {
    id: 4,
    athena_id: 11,
    name: "Well Visit",
    duration: 20,
    short_description: "Regular check-up",
    long_description: "A regular check-up that is typically scheduled every few months up until age 2 and annually thereafter.",
    hidden: false
  },

  {
    id: 5,
    athena_id: 14,
    name: "Block",
    duration: 10,
    short_description: "Block",
    long_description: "Block",
    hidden: true
  }
]

appointment_types_seed.each do |param|
  if appointment_type = AppointmentType.find_by(id: param[:id])
    appointment_type.update_attributes!(param)
  else
    AppointmentType.create!(param)
  end
end

appointment_statuses_seed = [
    {
      id: 1,
      description: "Checked In",
      status: "2"
    },

    {
      id: 2,
      description: "Checked Out",
      status: "3"
    },

    {
      id: 3,
      description: "Charge Entered",
      status: "4"
    },

    {
      id: 4,
      description: "Future",
      status: "f"
    },

    {
      id: 5,
      description: "Open",
      status: "o"
    },

    {
      id: 6,
      description: "Cancelled",
      status: "x"
    }
]

appointment_statuses_seed.each do |param|
  if appointment_status = AppointmentStatus.find_by(id: param[:id])
    appointment_status.update_attributes!(param)
  else
    AppointmentStatus.create!(param)
  end
end

insurance_plan_seed = [
  {
    insurer: {
      id: 1,
      insurer_name:"Aetna"
    },
    plans: [
             {id: 1, plan_name: "Choice", insurer_id: 1},
             {id: 2, plan_name: "Referral", insurer_id: 1},
             {id: 3, plan_name: "Value Performance", insurer_id: 1},
             {id: 4, plan_name: "Managed Choice", insurer_id: 1},
             {id: 5, plan_name: "Select", insurer_id: 1},
             {id: 6, plan_name: "EPO", insurer_id: 1},
             {id: 7, plan_name: "Elect", insurer_id: 1},
             {id: 8, plan_name: "National Advantage", insurer_id: 1},
             {id: 9, plan_name: "Open Choice", insurer_id: 1},
             {id: 10, plan_name: "QPOS", insurer_id: 1},
             {id: 11, plan_name: "Voluntary", insurer_id: 1},
             {id: 12, plan_name: "PPO", insurer_id: 1},
             {id: 13, plan_name: "POS", insurer_id: 1}
           ]
  },

  {
    insurer: {
      id: 2,
      insurer_name:"Cigna"
    },
    plans: [
             {id: 14, plan_name: "Network", insurer_id: 2},
             {id: 15, plan_name: "HMO", insurer_id: 2},
             {id: 16, plan_name: "Open Access", insurer_id: 2},
             {id: 17, plan_name: "Choice Fund", insurer_id: 2},
             {id: 18, plan_name: "POS", insurer_id: 2},
             {id: 19, plan_name: "PPO", insurer_id: 2}
           ]
  },


  {
    insurer: {
      id: 3,
      insurer_name:"Empire Blue Cross Blue Shield"
    },
    plans: [
             {id: 20, plan_name: "Access", insurer_id: 3},
             {id: 21, plan_name: "GuidedAccess", insurer_id: 3},
             {id: 22, plan_name: "HealthPlus", insurer_id: 3},
             {id: 23, plan_name: "Pathway", insurer_id: 3},
             {id: 24, plan_name: "Healthy", insurer_id: 3},
             {id: 25, plan_name: "Hospital", insurer_id: 3},
             {id: 26, plan_name: "Prism", insurer_id: 3},
             {id: 27, plan_name: "Indemnity", insurer_id: 3},
             {id: 28, plan_name: "TotalBlue", insurer_id: 3},
             {id: 29, plan_name: "Unite Here", insurer_id: 3},
             {id: 30, plan_name: "HSA", insurer_id: 3},
             {id: 31, plan_name: "PPO", insurer_id: 3},
             {id: 32, plan_name: "POS", insurer_id: 3},
             {id: 33, plan_name: "HMO", insurer_id: 3},
             {id: 34, plan_name: "EPO", insurer_id: 3}
           ]
  },

  {
    insurer: {
      id: 4,
      insurer_name:"United Healthcare"
    },
    plans: [
             {id: 35, plan_name: "Core", insurer_id: 4},
             {id: 36, plan_name: "Navigate", insurer_id: 4},
             {id: 37, plan_name: "Passport Connect", insurer_id: 4},
             {id: 38, plan_name: "Options", insurer_id: 4},
             {id: 39, plan_name: "Select", insurer_id: 4},
             {id: 40, plan_name: "Medica Choice", insurer_id: 4},
             {id: 41, plan_name: "PacifiCare", insurer_id: 4},
             {id: 42, plan_name: "PPO", insurer_id: 4},
             {id: 43, plan_name: "HMO", insurer_id: 4}
           ]
  }
]

insurance_plan_seed.each do |insurance_plan|
  if insurer = Insurer.find_by(id: insurance_plan[:insurer][:id])
    insurer.update_attributes!(insurance_plan[:insurer])
  else
    Insurer.create!(insurance_plan[:insurer])
  end

  insurance_plan[:plans].each do |plan|
    if insurance_plan = InsurancePlan.find_by(id: plan[:id])
      insurance_plan.update_attributes!(plan)
    else
      InsurancePlan.create!(plan)
    end
  end
end

onboarding_group_seed = [
  {
    id: 1,
    group_name: :invited_secondary_guardian
  }
]


onboarding_group_seed.each do |onboarding_group_param|
  if onboarding_group = OnboardingGroup.find_by(id: onboarding_group_param[:id])
    onboarding_group.update_attributes!(onboarding_group_param)
  else
    OnboardingGroup.create!(onboarding_group_param)
  end
end

#Seed the database with growth curves
begin
  folder = "lib/assets/percentile/oct_2015"
  optionsWho = { :col_sep => "\t", :headers => true }
  optionsCdc = { :headers => true }

  HeightGrowthCurve.delete_all

  #populate boys 0-24 months height
  CSV.foreach("#{folder}/lhfa_boys_p_exp.txt", optionsWho) do |row|
    entry = HeightGrowthCurve.new({ :sex=> "M", :days => row["Day"], :l => row["L"], :m => row["M"], :s => row["S"]})
    entry.save! if (entry.days <= 712)
  end

  #populate girls 0-24 months height
  CSV.foreach("#{folder}/lhfa_girls_p_exp.txt", optionsWho) do |row|
    entry = HeightGrowthCurve.new({ :sex=> "F", :days => row["Day"], :l => row["L"], :m => row["M"], :s => row["S"]})
    entry.save! if (entry.days <= 712)
  end

  #populate boys & girls 2-20 years height
  CSV.foreach("#{folder}/statage.csv", optionsCdc) do |row|
    entry = HeightGrowthCurve.new({
      #Sex==1 for boys, 2 for girls
      :sex=> (row["Sex"] == "1" ? "M" : "F"),
      :days => (row["Agemos"].to_i * 365 / 12),
      :l => row["L"],
      :m => row["M"],
      :s => row["S"]})
    entry.save! if (entry.days > 712 && row["Agemos"] != "24")
  end

  WeightGrowthCurve.delete_all

  #populate boys 0-24 months weight
  CSV.foreach("#{folder}/wfa_boys_p_exp.txt", optionsWho) do |row|
    entry = WeightGrowthCurve.new({ :sex=> "M", :days => row["Age"], :l => row["L"], :m => row["M"], :s => row["S"]})
    entry.save! if (entry.days <= 712)
  end

  #populate girls 0-24 months weight
  CSV.foreach("#{folder}/wfa_girls_p_exp.txt", optionsWho) do |row|
    entry = WeightGrowthCurve.new({ :sex=> "F", :days => row["Age"], :l => row["L"], :m => row["M"], :s => row["S"]})
    entry.save! if (entry.days <= 712)
  end

  #populate boys & girls 2-20 years weight
  CSV.foreach("#{folder}/wtage.csv", optionsCdc) do |row|
    entry = WeightGrowthCurve.new({
      #Sex==1 for boys, 2 for girls
      :sex=> (row["Sex"] == "1" ? "M" : "F"),
      :days => (row["Agemos"].to_i * 365 / 12),
      :l => row["L"],
      :m => row["M"],
      :s => row["S"]})
    entry.save! if (entry.days > 712 && row["Agemos"] != "24")
  end

  BmiGrowthCurve.delete_all

  #populate boys 0-24 months bmi
  CSV.foreach("#{folder}/bfa_boys_p_exp.txt", optionsWho) do |row|
    entry = BmiGrowthCurve.new({ :sex=> "M", :days => row["Age"], :l => row["L"], :m => row["M"], :s => row["S"]})
    entry.save! if (entry.days <= 712)
  end

  #populate girls 0-24 months bmi
  CSV.foreach("#{folder}/bfa_girls_p_exp.txt", optionsWho) do |row|
    entry = BmiGrowthCurve.new({ :sex=> "F", :days => row["Age"], :l => row["L"], :m => row["M"], :s => row["S"]})
    entry.save! if (entry.days <= 712)
  end

  #populate boys & girls 2-20 years bmi
  CSV.foreach("#{folder}/bmiagerev.csv", optionsCdc) do |row|
    entry = BmiGrowthCurve.new({
      #Sex==1 for boys, 2 for girls
      :sex=> (row["Sex"] == "1" ? "M" : "F"),
      :days => (row["Agemos"].to_i * 365 / 12),
      :l => row["L"],
      :m => row["M"],
      :s => row["S"]})
    entry.save! if (entry.days > 712 && row["Agemos"] != "24")
  end

  practice_schedules = [
    {
      id: 1,
      practice_id: 1,
      active: true,
      schedule_type: :default,
      monday_start_time: "08:00",
      monday_end_time: "20:00",
      tuesday_start_time: "08:00",
      tuesday_end_time: "18:00",
      wednesday_start_time: "10:00",
      wednesday_end_time: "20:00",
      thursday_start_time: "08:00",
      thursday_end_time: "18:00",
      friday_start_time: "09:00",
      friday_end_time: "17:00",
      saturday_start_time: "00:00",
      saturday_end_time: "00:00",
      sunday_start_time: "00:00",
      sunday_end_time: "00:00"
    },

    {
      id: 2,
      practice_id: 1,
      active: false,
      schedule_type: :emergency,
      monday_start_time: "08:00",
      monday_end_time: "20:00",
      tuesday_start_time: "08:00",
      tuesday_end_time: "18:00",
      wednesday_start_time: "10:00",
      wednesday_end_time: "20:00",
      thursday_start_time: "08:00",
      thursday_end_time: "18:00",
      friday_start_time: "09:00",
      friday_end_time: "17:00",
      saturday_start_time: "00:00",
      saturday_end_time: "00:00",
      sunday_start_time: "00:00",
      sunday_end_time: "00:00"
    },

    {
      id: 3,
      practice_id: 1,
      active: false,
      schedule_type: :holiday,
      monday_start_time: "08:00",
      monday_end_time: "20:00",
      tuesday_start_time: "08:00",
      tuesday_end_time: "18:00",
      wednesday_start_time: "10:00",
      wednesday_end_time: "20:00",
      thursday_start_time: "08:00",
      thursday_end_time: "18:00",
      friday_start_time: "09:00",
      friday_end_time: "17:00",
      saturday_start_time: "00:00",
      saturday_end_time: "00:00",
      sunday_start_time: "00:00",
      sunday_end_time: "00:00"
    },
  ]

  practice_schedules.each do |schedule_params|
    if practice_schedule = PracticeSchedule.find_by(id: schedule_params[:id])
      practice_schedule.update_attributes!(schedule_params)
    else
      PracticeSchedule.create!(schedule_params)
    end
  end

  #add holidays
  practice_holidays = [
    "01/01/2016", #New Year's Day
    "05/30/2016", #Memorial Day
    "07/04/2016", #Independence Day
    "09/05/2016", #Labor Day
    "11/24/2016", #Thanksgiving
    "12/25/2016"  #Christmas
  ]

  ProviderLeave.where(athena_id: 0).delete_all

  ProviderSyncProfile.all.each do |provider_sync_profile|
    practice_holidays.each do | holiday |
      ProviderLeave.create(
        athena_id: 0,
        athena_provider_id: provider_sync_profile.athena_id,
        description: "Seeded holiday",
        start_datetime: AthenaHealthApiHelper.to_datetime(holiday, "00:00"),
        end_datetime: AthenaHealthApiHelper.to_datetime(holiday, "00:00") + 24.hours
      )
    end
  end

  #add a dummy patient that will be used for syncing appointments from Athena
  syncServiceUser = User.create_with(first_name: 'Guardian', last_name: 'SyncService', password: 'SyncService-password', phone: '0000000000', role: Role.find(4), practice: Practice.first)
    .find_or_create_by!(email: 'sync@leohealth.com')
  Patient.create_with(first_name: 'Patient', last_name: 'SyncService', birth_date: Date.today, sex: 'M')
    .find_or_create_by!(family: syncServiceUser.family)

end
