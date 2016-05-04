namespace :backfill do
  desc 'PUT patients to ensure a departmentid exists'
  task patient_departemnt_ids: :environment do
    #TODO: load from source
    patient_ids = [1147]
    departmentid = Practice.flatiron_pediatrics.athena_id
    @connector = AthenaHealthApiHelper::AthenaHealthApiConnector.instance
    patient_ids.map do |patient_id|
      begin
        @connector.update_patient(patientid: patient_id, departmentid: departmentid)
        print "#{patient_id} "
      rescue Exception => e
        puts "\nFailed to update patient #{patient_id}: Error: #{e}"
      end
    end
    puts "\nFinished"
  end
end
