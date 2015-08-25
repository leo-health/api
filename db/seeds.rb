ROLES = {
          # Super user / admin
          super_user: 0,
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
          patient: 6
        }

ROLES.each do |role, id|
  Role.update_or_create_by_id_and_name(id, role) do |r|
    r.save
  end
end

AppointmentTypes = {
    well_visit: {
      id: 0,
      name: "well visit",
      duration: 30,
      short_description: "Regular check-up",
      long_description: "A regular check-up that is typically scheduled every few months up until age 2 and annually thereafter."
    },

    sick_visit: {
      id: 1,
      name: "sick visit",
      duration: 20,
      short_description: "New symptom",
      long_description: "A visit to address new symptoms like cough, cold, ear pain, fever, diarrhea, or rash."
    },

    follow_up_visit: {
      id: 2,
      name: "follow_up visit",
      duration: 20,
      short_description: "Unresolved illness or chronic condition",
      long_description: "A visit to follow up on a known condition like asthma, ADHD, or eczema."
    },

    immunization_visit: {
      id: 3,
      name: "immunization visit",
      duration: 20,
      short_description: "Flu shot or scheduled vaccine",
      long_description: "A visit with a nurse to get one or more immunizations."
    }


}

AppointmentTypes.each do |name, param|
  AppointmentType.create(param) unless AppointmentType.where(name: name).exists?
end

Practices = {
  leo_chelsea: {
    id: 0,
    name: "Leo @ Chelsea",
    address_line_1: "33w 17th St",
    address_line_2: "5th floor",
    city: "New York",
    state: "NY",
    zip: "10011",
    fax: "10543",
    phone: "101-101-1001",
    email: "info@leohealth.com"
  }
}

Practices.each do |name, param|
  Practice.create(param) unless Practice.where(name: name).exists?
end
