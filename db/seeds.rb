require 'csv'

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
    r.save
  end
end

staff = {
  bot: {
    first_name: "Leo",
    last_name: "Bot",
    birth_date: Time.now,
    sex: "M",
    email: "leo_bot@leohealth.com",
    password: "password",
    password_confirmation: "password",
    role_id: 7,
    practice_id: 1,
    phone: '1234567890',
    # avatar_attributes: {
    #   avatar: Base64.encode64(open(File.new(Rails.root.join('db', 'seed_images', 'Avatar_Guardian_Mom.png'))){|io|io.read})
    # }
  },

  vriese: {
    title: "Dr.",
    first_name: "Victoria",
    last_name: "Riese",
    sex: "F",
    email: "vriesemd@gmail.com",
    password: "password",
    password_confirmation: "password",
    role_id: 5,
    practice_id: 1,
    phone: '+19177976816',
    # avatar_attributes: {
    #   avatar: Base64.encode64(open(File.new(Rails.root.join('db', 'seed_images', 'Avatar_Guardian_Mom.png'))){|io|io.read})
    # },

    provider_profile_attributes: {
      athena_id: 4,
      athena_department_id: 2,
      specialties: "",
      credentials: ["MD"]
    }
  },

  hgold: {
    first_name: "Erin",
    last_name: "Gold",
    sex: "F",
    email: "ehannah29@gmail.com",
    password: "password",
    password_confirmation: "password",
    role_id: 5,
    practice_id: 1,
    phone: '+16177912619',
    provider_profile_attributes: {
      athena_id: 3,
      athena_department_id: 2,
      specialties: "",
      credentials: ["NP"]
    }
  },

  mbrody: {
    first_name: "Marcey",
    last_name: "Brody",
    sex: "F",
    email: "nurse@flatironpediatrics.com",
    password: "password",
    password_confirmation: "password",
    role_id: 2,
    practice_id: 1,
    phone: '+16302122713',
    provider_profile_attributes: {
      specialties: "",
      credentials: ["RN"]
    }
  },
  #
  # cfranco: {
  #   first_name: "Catherine",
  #   last_name: "Franco",
  #   sex: "F",
  #   email: "cathy424@hotmail.com",
  #   password: "password",
  #   password_confirmation: "password",
  #   role_id: 3,
  #   practice_id: 1,
  #   phone: '+19176929777',
  #   credentials: ["Office Manager"]
  # },
  #
  # kcastellano: {
  #   first_name: "Kristen",
  #   last_name: "Castellano",
  #   sex: "F",
  #   email: "Inquiry@flatironpediatrics.com",
  #   password: "password",
  #   password_confirmation: "password",
  #   role_id: 1,
  #   practice_id: 1,
  #   phone: '+19736327321',
  #   credentials: ["RN"]
  # }
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
  user = User.create(attributes)

  if user.valid?
    # if user.has_role? :clinical
    #   provider_profile = {
    #       athena_id: attributes[:athena_id],
    #       athena_department_id: attributes[:athena_department_id],
    #       provider_id: user.id,
    #       specialties: attributes[:specialties],
    #       credentials: attributes[:credentials]
    #   }
    #   user.create_provider_profile!(provider_profile)
    #
    #   default_schedule[:athena_provider_id] = attributes[:athena_id]
    #   ProviderSchedule.create!(default_schedule)
    # end
    print "*"
  else
    print "x"
    puts "Failed to seed staff users - #{user.errors.full_messages}"
    false
  end
end

appointment_types_seed = [
  {
    id: 1,
    name: "Sick Visit",
    duration: 20,
    short_description: "New symptom",
    long_description: "A visit to address new symptoms like cough, cold, ear pain, fever, diarrhea, or rash."
  },

  {
    id: 2,
    name: "Follow Up Visit",
    duration: 20,
    short_description: "Unresolved illness or chronic condition",
    long_description: "A visit to follow up on a known condition like asthma, ADHD, or eczema."
  },

  {
    id: 3,
    name: "Immunization / Lab Visit",
    duration: 20,
    short_description: "Flu shot or scheduled vaccine",
    long_description: "A visit with a nurse to get one or more immunizations."
  },

  {
    id: 4,
    name: "Well Visit",
    duration: 30,
    short_description: "Regular check-up",
    long_description: "A regular check-up that is typically scheduled every few months up until age 2 and annually thereafter."
  }
]

appointment_types_seed.each do |param|
  AppointmentType.create(param) unless AppointmentType.where(id: param[:id]).exists?
end

practices_seed = {
  "Leo @ Chelsea": {
    id: 1,
    name: "Leo @ Chelsea",
    address_line_1: "33w 17th St",
    address_line_2: "5th floor",
    city: "New York",
    state: "NY",
    zip: "10011",
    fax: "10543",
    phone: "101-101-1001",
    email: "info@leohealth.com",
    time_zone: "Eastern Time (US & Canada)"
  }
}

practices_seed.each do |name, param|
  Practice.create(param) unless Practice.where(name: name).exists?
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
  AppointmentStatus.create(param) unless AppointmentStatus.where(id: param[:id]).exists?
end

insurance_plan_seed = [
    {
      insurer: {
        id: 1,
        insurer_name:"Cigna"
      },
      plans: [
               {id: 3, plan_name: "PPO", insurer_id: 1},
               {id: 4, plan_name: "POS", insurer_id: 1},
               {id: 5, plan_name: "HMO", insurer_id: 1}
             ]
    },

    {
      insurer: {
        id: 2,
        insurer_name:"Empire BlueCross BlueShield"
      },
      plans: [
               {id: 6, plan_name: "PPO", insurer_id: 2},
               {id: 7, plan_name: "POS", insurer_id: 2},
               {id: 8, plan_name: "HMO", insurer_id: 2}
             ]
    },

    {
      insurer: {
        id: 3,
        insurer_name:"EmblemHealth"
      },
      plans: [
               {id: 9, plan_name: "PPO", insurer_id: 3},
               {id: 10, plan_name: "POS", insurer_id: 3},
               {id: 11, plan_name: "HMO", insurer_id: 3}
             ]
    },

    {
      insurer: {
        id: 4,
        insurer_name:"MultiPlan"
      },
      plans: [
               {id: 12, plan_name: "PPO", insurer_id: 4},
               {id: 13, plan_name: "POS", insurer_id: 4}
             ]
    },

    {
      insurer: {
        id: 5,
        insurer_name:"Oxford"
      },
      plans: [
               {id: 14, plan_name: "PPO", insurer_id: 5},
               {id: 15, plan_name: "POS", insurer_id: 5},
               {id: 16, plan_name: "HMO", insurer_id: 5}
             ]
    },

    {
      insurer: {
        id: 6,
        insurer_name:"The Empire Plan"
      },
      plans: [
               {id: 17, plan_name: "PPO", insurer_id: 6},
               {id: 18, plan_name: "POS", insurer_id: 6},
               {id: 19, plan_name: "HMO", insurer_id: 6}
             ]
    },

    {
      insurer: {
        id: 7,
        insurer_name:"UnitedHealthcare"
      },
      plans: [
               {id: 20, plan_name: "PPO", insurer_id: 7},
               {id: 21, plan_name: "POS", insurer_id: 7},
               {id: 22, plan_name: "HMO", insurer_id: 7}
             ]
    },
    {
      insurer: {
        id: 8,
        insurer_name:"Aetna"
      },
      plans: [
               {id: 23, plan_name: "PPO", insurer_id: 8},
               {id: 24, plan_name: "POS", insurer_id: 8},
               {id: 25, plan_name: "HMO", insurer_id: 8}
             ]
    }
]

insurance_plan_seed.each do |insurance_plan|
  Insurer.create(insurance_plan[:insurer]) unless Insurer.where(id: insurance_plan[:insurer][:id]).exists?
  insurance_plan[:plans].each do |plan|
    InsurancePlan.create(plan) unless InsurancePlan.where(id: plan[:id]).exists?
  end
end

onboarding_group_seed = [
  {
    id: 1,
    group_name: :invited_secondary_guardian
  }
]


onboarding_group_seed.each do |onboarding_group|
  OnboardingGroup.create(onboarding_group) unless OnboardingGroup.where(id: onboarding_group[:id]).exists?
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
    entry.save if (entry.days <= 712)
  end

  #populate girls 0-24 months height
  CSV.foreach("#{folder}/lhfa_girls_p_exp.txt", optionsWho) do |row|
    entry = HeightGrowthCurve.new({ :sex=> "F", :days => row["Day"], :l => row["L"], :m => row["M"], :s => row["S"]})
    entry.save if (entry.days <= 712)
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
    entry.save if (entry.days > 712 && row["Agemos"] != "24")
  end

  WeightGrowthCurve.delete_all

  #populate boys 0-24 months weight
  CSV.foreach("#{folder}/wfa_boys_p_exp.txt", optionsWho) do |row|
    entry = WeightGrowthCurve.new({ :sex=> "M", :days => row["Age"], :l => row["L"], :m => row["M"], :s => row["S"]})
    entry.save if (entry.days <= 712)
  end

  #populate girls 0-24 months weight
  CSV.foreach("#{folder}/wfa_girls_p_exp.txt", optionsWho) do |row|
    entry = WeightGrowthCurve.new({ :sex=> "F", :days => row["Age"], :l => row["L"], :m => row["M"], :s => row["S"]})
    entry.save if (entry.days <= 712)
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
    entry.save if (entry.days > 712 && row["Agemos"] != "24")
  end

  BmiGrowthCurve.delete_all

  #populate boys 0-24 months bmi
  CSV.foreach("#{folder}/bfa_boys_p_exp.txt", optionsWho) do |row|
    entry = BmiGrowthCurve.new({ :sex=> "M", :days => row["Age"], :l => row["L"], :m => row["M"], :s => row["S"]})
    entry.save if (entry.days <= 712)
  end

  #populate girls 0-24 months bmi
  CSV.foreach("#{folder}/bfa_girls_p_exp.txt", optionsWho) do |row|
    entry = BmiGrowthCurve.new({ :sex=> "F", :days => row["Age"], :l => row["L"], :m => row["M"], :s => row["S"]})
    entry.save if (entry.days <= 712)
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
    entry.save if (entry.days > 712 && row["Agemos"] != "24")
  end

  practice_schedules = [
    {
      id: 1,
      practice_id: 1,
      active: true,
      schedule_type: :default,
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
    },

    {
      id: 2,
      practice_id: 1,
      active: false,
      schedule_type: :emergency,
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
    },

    {
      id: 3,
      practice_id: 1,
      active: false,
      schedule_type: :holiday,
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
    },
  ]

  practice_schedules.each do |schedule_params|
    PracticeSchedule.create(schedule_params) unless PracticeSchedule.where(id: schedule_params[:id]).exists?
  end
end
