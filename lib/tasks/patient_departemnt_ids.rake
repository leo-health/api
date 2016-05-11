namespace :backfill do
  desc 'PUT patients to ensure a departmentid exists'
  task patient_department_ids: :environment do
    #TODO: load from source
    patient_ids = File.readlines('lib/assets/patient_ids.txt').map(&:to_i)
    byebug
    departmentid = Practice.flatiron_pediatrics.athena_id
    @connector = AthenaHealthApiHelper::AthenaHealthApiConnector.instance

    patient_ids -= @connector.get_patients(departmentid: departmentid).map { |patient| patient["patientid"].try(:to_i) }

    byebug
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
