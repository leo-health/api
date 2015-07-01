# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
ROLES = {
          # Super user / admin
          super_user: 0,
          # Accounting and billing
          billing: 1,
          # Non-provider roles (MA, nurse, NP)
          clinical_support: 2,
          # Leo staff and reception
          customer_service: 3,
          # Parent and legal guardians
          parent: 4,
          # Pediatricians and other providers
          physician: 5,
          #Children
          child: 6
        }

ROLES.each do |role, id|
  Role.update_or_create_by_id_and_name(id, role) do |r|
    r.save
  end
end
