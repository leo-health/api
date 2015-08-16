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

#
# AppointmentTypes
#
#
#
# {
#     "id": 0,
#     "type_id": 0,
#     "type": "well",
#     "name": "well visit",
#     "duration": 30,
#     "short_description": "Regular check-up",
#     "long_description": "A regular check-up that is typically scheduled every few months up until age 2 and annually thereafter."
# },
#     {
#         "id": 1,
#         "type_id": 1,
#         "type": "sick",
#         "name": "sick visit",
#         "duration": 20,
#         "short_description": "New symptom",
#         "long_description": "A visit to address new symptoms like cough, cold, ear pain, fever, diarrhea, or rash."
#     },
#     {
#         "id": 2,
#         "type_id": 2,
#         "type": "follow_up",
#         "name": "follow up visit",
#         "duration": 20,
#         "short_description": "Unresolved illness or chronic condition",
#         "long_description": "A visit to follow up on a known condition like asthma, ADHD, or eczema."
#     },
#     {
#         "id": 3,
#         "type_id": 3,
#         "type": "immunization",
#         "name": "immunization visit",
#         "duration": 20,
#         "short_description": "Flu shot or scheduled vaccine",
#         "long_description": "A visit with a nurse to get one or more immunizations."
#     }
