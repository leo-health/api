# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
ROLES = {
          # Admin is 1
          admin: 1,
          # Leo users are 10-19
          physician: 11,
          clinical_staff: 12,
          other_staff: 13,
          # Leo customers are 20-29
          parent: 21,
          child: 22,
          guardian: 23
        }

ROLES.each do |role, id|
  Role.update_or_create_by_id_and_name(id, role) do |r|
    r.save
  end
end
