namespace :backfill do
  desc 'back fill vendor_id on user'
  task vendor_id: :environment do
    Enrollment.where(vendor_id: nil).find_each do |enrollment|
      vendor_id = loop do
        random_token = SecureRandom.urlsafe_base64(nil, false)
        break random_token unless Enrollment.exists?(vendor_id: random_token)
      end

      print "failed to set vendor id for enrollment #{enrollment.id}" unless enrollment.update_attributes(vendor_id: vendor_id)
      if user = User.find_by_email(enrollment.email) && !user.vendor_id
        if user.update_attributes(vendor_id: enrollment.vendor_id)
          puts "*"
        else
          print "failed to set vendor if for user #{user.id}"
        end
      end
    end
  end
end
