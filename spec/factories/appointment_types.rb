FactoryGirl.define do
  factory :appointment_type do
    id 0
    athena_id 0
    name "well visit"
    duration 30
    short_description "Regular check-up"
    long_description "A regular check-up that is typically scheduled every few months up until age 2 and annually thereafter."
    initialize_with { AppointmentType.find_or_create_by(id: id)}
    hidden false

    trait :well_visit do
      id 0
      athena_id 0
      name "well visit"
      duration 30
      short_description "Regular check-up"
      long_description "A regular check-up that is typically scheduled every few months up until age 2 and annually thereafter."
      hidden false
    end

    trait :sick_visit do
      id 1
      athena_id 0
      name "sick visit"
      duration 20
      short_description "New symptom"
      long_description "A visit to address new symptoms like cough, cold, ear pain, fever, diarrhea, or rash."
      hidden false
    end

    trait :follow_up_visit do
      id 2
      athena_id 0
      name "follow_up visit"
      duration 20
      short_description "Unresolved illness or chronic condition"
      long_description "A visit to follow up on a known condition like asthma, ADHD, or eczema."
      hidden false
    end

    trait :immunization_visit do
      id 3
      athena_id 0
      name "immunization visit"
      duration 20
      short_description "Flu shot or scheduled vaccine"
      long_description "A visit with a nurse to get one or more immunizations."
      hidden false
    end

    trait :block do
      id 5
      athena_id 0
      name "Block"
      duration 10
      short_description "Block"
      long_description "Block"
      hidden true
    end
  end
end
