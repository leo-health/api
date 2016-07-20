namespace :backfill do
  desc 'back fill vendor_id on user'
  task vendor_id: :environment do
    Enrollment.where(vendor_id: nil).find_each do |enrollment|
      vendor_id = GenericHelper.generate_token(:vendor_id)
      print "failed to set vendor id for enrollment #{enrollment.id}" unless enrollment.update_attributes(vendor_id: vendor_id)
      user = User.find_by_email(enrollment.email)
      if user && !user.vendor_id
        if user.update_attributes(vendor_id: enrollment.vendor_id)
          puts "*"
        else
          print "failed to set vendor if for user #{user.id}"
        end
      end
    end
  end
end
