#
# Groups:
#   Super User:
#     0
#   Staff:
#     1, 2, 3, 5
#   Family:
#     4, 6
#
ROLES = {
          # Super user / admin
          super_user: 0,
          # Accounting and billing
          billing: 1,
          # Non-provider roles (medical assistant, nurse practicioner)
          clinical_support: 2,
          # Leo staff and reception
          customer_service: 3,
          # Parent and legal guardians
          parent: 4,
          # Pediatricians and other care providers
          physician: 5,
          # Children
          child: 6
        }

ROLES.each do |role, id|
  Role.update_or_create_by_id_and_name(id, role) do |r|
    r.save
  end
end
