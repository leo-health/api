require "athena_health_api"

module AthenaHealthApiHelper
  def self.to_datetime(athena_date, athena_time)
    date = Date.strptime(athena_date, '%m/%d/%Y')
    Time.zone.parse("#{date.to_s} #{athena_time}").to_datetime
  end

  #athena appointmentstatus
  #The athenaNet appointment status.
  #x=cancelled
  #f=future (f can include appointments where were never checked in, even if the appointment date is in the past. It is up to a practice to cancel appointments as a no show when appropriate to do so.)
  #o=open
  #2=checked in
  #3=checked out
  #4=charge entered (i.e. a past appointment).
  class AthenaStruct
    def initialize(args)
      args.each do |k,v|
        add_field(k,v)
      end
    end

    def add_field(k, v)
      instance_variable_set("@#{k}", v)
      self.class.send(:attr_accessor, "#{k}")
    end

    def booked?
      future? || checked_in? || checked_out? || charge_entered?
    end

    def pre_checked_in?
      future? || open? || cancelled?
    end

    def post_checked_in?
      !pre_checked_in
    end

    def cancelled?
      @appointmentstatus == "x"
    end

    def checked_in?
      @appointmentstatus == "2"
    end

    def checked_out?
      @appointmentstatus == "3"
    end

    def charge_entered?
      @appointmentstatus == "4"
    end

    def future?
      @appointmentstatus == "f"
    end

    def open?
      @appointmentstatus == "o"
    end
  end

  class AthenaHealthApiConnector
    attr_reader :connection

    #for some reason, gzip encoding returns invalid blocks in failure cases
    def self.common_headers
      { "Accept-Encoding" => "deflate;q=0.6,identity;q=0.3" }
    end

    def initialize(
      key: ENV["ATHENA_KEY"],
      secret: ENV["ATHENA_SECRET"],
      version: ENV["ATHENA_VERSION"].to_s.empty? ? "preview1" : ENV["ATHENA_VERSION"],
      practice_id: ENV["ATHENA_PRACTICE_ID"].to_s.empty? ? "13092" : ENV["ATHENA_PRACTICE_ID"],
      connection: AthenaHealthAPI::Connection.new(version, key, secret, practice_id))

      @connection = connection
    end

    def get(path: , params: {})
      @connection.GET(path, params, AthenaHealthApiConnector.common_headers)
    end

    def put(path: , params: {})
      @connection.PUT(path, params, AthenaHealthApiConnector.common_headers)
    end

    def post(path: , params: {})
      @connection.POST(path, params, AthenaHealthApiConnector.common_headers)
    end

    def delete(path: , params: {})
      @connection.DELETE(path, params, AthenaHealthApiConnector.common_headers)
    end

    # obtain information on an athena appointment
    # returns an instance of AthenaStruct, nil of not found
    # raises exceptions if anything goes wrong
    def get_appointment(appointmentid: , showinsurance: false)

      params = {}
      params[:showinsurance] = showinsurance

      response = @connection.GET("appointments/#{appointmentid}", params, AthenaHealthApiConnector.common_headers)

      #410 means the appointment does not exist
      return nil if response.code.to_i == 410

      raise "HTTP error code encountered: #{response.code}" unless response.code.to_i == 200

      return AthenaStruct.new(JSON.parse(response.body)[0])
    end

    # delete an open appointment
    # no return value
    # raises exceptions if anything goes wrong
    def delete_appointment(appointmentid: )
      params = {}

      response = @connection.DELETE("appointments/#{appointmentid}", params, AthenaHealthApiConnector.common_headers)

      raise "HTTP error code encountered: #{response.code}" unless response.code.to_i == 200
    end

    # create open appointment in athena
    # returns the id of the newly created appointment
    # raises exceptions if anything goes wrong in the process

    def create_appointment(appointmentdate: , appointmenttime:,
      appointmenttypeid: nil, departmentid: , providerid: , reasonid: nil)

      params = Hash[method(__callee__).parameters.select{|param| eval(param.last.to_s) }.collect{|param| [param.last, eval(param.last.to_s)]}]
      response = @connection.POST("appointments/open", params, AthenaHealthApiConnector.common_headers)

      raise "HTTP error code encountered: #{response.code}" unless response.code.to_i == 200

      val = JSON.parse(response.body)

      raise "unexpected size of appointmentids encountered: #{val[:appointmentids.to_s].length}" unless val[:appointmentids.to_s].length == 1

      return val[:appointmentids.to_s].keys[0].to_i
    end

    # books an appointment slot for a specified patient
    # An open appointment must already exist.
    # raises exceptions if anything goes wrong in the process
    def book_appointment(appointmentid: ,
      appointmenttypeid: nil, bookingnote: nil, departmentid: nil, ignoreschedulablepermission: true,
      insurancecompany: nil, insurancegroupid: nil, insuranceidnumber: nil, insurancenote: nil,
      insurancephone: nil, insuranceplanname: nil, insurancepolicyholder: nil, nopatientcase: false,
      patientid: , patientrelationshiptopolicyholder: nil, reasonid: nil)

      params = Hash[method(__callee__).parameters.select{|param| eval(param.last.to_s) }.collect{|param| [param.last, eval(param.last.to_s)]}]
      response = @connection.PUT("appointments/#{appointmentid}", params, AthenaHealthApiConnector.common_headers)

      raise "HTTP error code encountered: #{response.code}" unless response.code.to_i == 200
    end

    # cancel a booked appointment
    # A booked appointment must already exist.
    # raises exceptions if anything goes wrong in the process
    def cancel_appointment(appointmentid: ,
      cancellationreason: nil, ignoreschedulablepermission: true, nopatientcase: false, patientid: )

      params = {}
      params[:cancellationreason] = cancellationreason if cancellationreason
      params[:ignoreschedulablepermission] = ignoreschedulablepermission
      params[:patientid] = patientid

      response = @connection.PUT("appointments/#{appointmentid}/cancel", params, AthenaHealthApiConnector.common_headers)

      raise "HTTP error code encountered: #{response.code}" unless response.code.to_i == 200
    end

    # reschedule a booked appointment
    # A booked appointment must already exist.
    # raises exceptions if anything goes wrong in the process
    def reschedule_appointment(appointmentid: ,
      ignoreschedulablepermission: true, newappointmentid: , nopatientcase: false, patientid: ,
      reasonid: nil, reschedulereason: nil)

      params = Hash[method(__callee__).parameters.select{|param| eval(param.last.to_s) }.collect{|param| [param.last, eval(param.last.to_s)]}]
      response = @connection.PUT("appointments/#{appointmentid}/reschedule", params, AthenaHealthApiConnector.common_headers)

      raise "HTTP error code encountered: #{response.code}" unless response.code.to_i == 200
    end

    # freezes/unfreezes an appointment
    def freeze_appointment(appointmentid:, freeze: true)
      params = Hash[method(__callee__).parameters.select{|param| eval(param.last.to_s) }.collect{|param| [param.last, eval(param.last.to_s)]}]
      response = @connection.PUT("appointments/#{appointmentid}/freeze", params, AthenaHealthApiConnector.common_headers)

      raise "HTTP error code encountered: #{response.code}" unless response.code.to_i == 200
    end

    # create open appointment in athena
    # returns the id of the newly created appointment
    # raises exceptions if anything goes wrong in the process
    def checkin_appointment(appointmentid:)
      params = {}
      params[:appointmentid] = appointmentid

      response = @connection.POST("appointments/#{appointmentid}/checkin", params, AthenaHealthApiConnector.common_headers)

      raise "HTTP error code encountered: #{response.code}" unless response.code.to_i == 200
    end

    # recursive function for retrieving a full dataset thorugh multiple GET calls.
    # returns an array of AthenaStructs
    # raises exceptions if anything goes wrong in the process
    def get_paged(url: , params: , headers: , field: , offset: 0, limit: 5000, structize: false)
      raise "limit #{limit} is higher then max allowed 5000." if limit > 5000

      local_params = params.clone
      local_params['offset'] = offset
      local_params['limit'] = limit

      response = @connection.GET(url, local_params, headers)

      raise "HTTP error code encountered: #{response.code}" unless response.code.to_i == 200

      parsed = JSON.parse(response.body)

      entries = []

      parsed[field.to_s].each do | val |
        if structize
          entries.push AthenaStruct.new val
        else
          entries.push val
        end
      end

      #add following pages of results
      if parsed[:next.to_s]
        entries.concat(
          get_paged(url: url,
            params: params, headers: headers, field: field, offset: offset + limit,
            limit: limit, structize: structize))
      end

      return entries
    end

    # get a list of available appointment types
    # returns an array of AthenaStructs
    # raises exceptions if anything goes wrong in the process
    def get_appointment_types(hidegeneric: false,
      hidenongeneric: false, hidenonpatient: false, hidetemplatetypeonly: true, limit: 5000)

      params = Hash[method(__callee__).parameters.select{|param| eval(param.last.to_s) }.collect{|param| [param.last, eval(param.last.to_s)]}]

      return get_paged(
        url: "/appointmenttypes", params: params,
        headers: AthenaHealthApiConnector.common_headers, field: :appointmenttypes, limit: limit)
    end

    # get a list of available appointment reasons
    # returns an array of AthenaStructs
    # raises exceptions if anything goes wrong in the process
    # todo: do we need separate calls for existing vs new patients
    def get_appointment_reasons(departmentid: ,
      providerid: , limit: 5000)

      params = Hash[method(__callee__).parameters.select{|param| eval(param.last.to_s) }.collect{|param| [param.last, eval(param.last.to_s)]}]

      return get_paged(
        url: "/patientappointmentreasons", params: params,
        headers: AthenaHealthApiConnector.common_headers, field: :patientappointmentreasons, limit: limit)
    end

    # get a list of open appointments
    # returns an array of AthenaStructs
    # raises exceptions if anything goes wrong in the process
    def get_open_appointments(
      appointmenttypeid: nil, bypassscheduletimechecks: true, departmentid:, enddate: nil,
      ignoreschedulablepermission: true, providerid: nil, reasonid: nil, showfrozenslots: false,
      startdate: nil, limit: 5000)

      params = Hash[method(__callee__).parameters.select{|param| eval(param.last.to_s) }.collect{|param| [param.last, eval(param.last.to_s)]}]

      return get_paged(
        url: "/appointments/open", params: params,
        headers: AthenaHealthApiConnector.common_headers, field: :appointments, limit: limit, structize: true)
    end

    # get a list of booked appointments
    # returns an array of AthenaStructs
    # raises exceptions if anything goes wrong in the process
    def get_booked_appointments(
      appointmenttypeid: nil, departmentid: , enddate: , endlastmodified: nil,
      ignorerestrictions: true, patientid: nil, providerid: nil, scheduledenddate: nil,
      scheduledstartdate: nil, showcancelled: true, showclaimdetail: false, showcopay: true,
      showinsurance: false, showpatientdetail: false, startdate:, startlastmodified: nil,
      limit: 5000)

      params = Hash[method(__callee__).parameters.select{|param| eval(param.last.to_s) }.collect{|param| [param.last, eval(param.last.to_s)]}]

      return get_paged(
        url: "/appointments/booked", params: params,
        headers: AthenaHealthApiConnector.common_headers, field: :appointments, limit: limit, structize: true)
    end

    #Get list of all patients: GET /preview1/:practiceid/patients
    def get_patients(departmentid: )
      params = Hash[method(__callee__).parameters.select{|param| eval(param.last.to_s) }.collect{|param| [param.last, eval(param.last.to_s)]}]

      return get_paged(
        url: "patients", params: params,
        headers: AthenaHealthApiConnector.common_headers, field: :patients)
    end

    #Create a patient: POST /preview1/:practiceid/patients
    #returns patient id
    #TODO: Doesn't seem to create a new patient when some of the records are the same.  Investigate.
    def create_patient(
      status: nil, #active, inactive, prospective, deleted
      firstname: ,
      lastname: ,
      sex: nil,
      dob: ,
      homephone: '0000000000',
      guarantormiddlename: nil,
      guarantorlastname: nil,
      guarantoraddress1: nil,
      guarantoraddress2: nil,
      guarantorstate: nil,
      guarantorzip: nil,
      guarantordob: nil,
      guarantoremail: ,
      guarantorphone: nil,
      departmentid: ,
      guarantorfirstname: nil,
      guarantorcity: nil,
      middlename: nil,
      guarantorssn: nil,
      guarantorrelationshiptopatient: nil,
      contactname: nil,
      contactrelationship: nil,
      contactmobilephone: nil
      )

      params = Hash[method(__callee__).parameters.select{|param| eval(param.last.to_s) }.collect{|param| [param.last, eval(param.last.to_s)]}]
      response = @connection.POST("patients", params, AthenaHealthApiConnector.common_headers)

      raise "HTTP error code encountered: #{response.code}" unless response.code.to_i == 200

      val = JSON.parse(response.body)

      raise "unexpected patient list len: #{val.length}" unless val.length == 1

      return val[0][:patientid.to_s].to_i
    end

    #Get a patient: GET /preview1/:practiceid/patients/:patientid
    #returns null if patient does not exist
    def get_patient(patientid: )
      response = @connection.GET("patients/#{patientid}", {}, AthenaHealthApiConnector.common_headers)

      #404 means the patient does not exist
      return nil if response.code.to_i == 404

      raise "HTTP error code encountered: #{response.code}" unless response.code.to_i == 200

      return AthenaStruct.new(JSON.parse(response.body)[0])
    end

    def get_best_match_patient(anyfirstname: nil, anyphone: nil, appointmentdepartmentid: nil, appointmentproviderid: nil,
                               dob: , email: nil, firstname: nil, guarantoremail: nil, guarantorphone: nil, homephone: nil,
                               ignorerestrictions: nil, lastname: , middlename: nil, mobilephone: nil, preferredname: nil,
                               showportalstatus: nil, ssn: nil, suffix: nil, upcomingappointmenthours: nil, workphone: nil,
                               zip: nil)

        params = Hash[method(__callee__).parameters.select{|param| eval(param.last.to_s) }.collect{|param| [param.last, eval(param.last.to_s)]}]

        response = @connection.GET("patients/bestmatch", params, AthenaHealthApiConnector.common_headers)

        raise "HTTP error code encountered: #{response.code}" unless response.code.to_i == 200

        result = JSON.parse(response.body)

        return nil if result.empty?
        return AthenaStruct.new(result[0])
    end

    #Update a patient: PUT /preview1/:practiceid/patients/:patientid
    def update_patient(
      patientid: ,
      status: nil, #active, inactive, prospective, deleted
      firstname: ,
      lastname: ,
      sex: ,
      dob: ,
      homephone: nil,
      guarantormiddlename: nil,
      guarantorlastname: nil,
      guarantoraddress1: nil,
      guarantoraddress2: nil,
      guarantorstate: nil,
      guarantorzip: nil,
      guarantordob: nil,
      guarantoremail: ,
      guarantorphone: nil,
      departmentid: ,
      guarantorfirstname: nil,
      guarantorcity: nil,
      middlename: nil,
      guarantorssn: nil,
      guarantorrelationshiptopatient: nil,
      contactname: nil,
      contactrelationship: nil,
      contactmobilephone: nil
      )

      params = Hash[method(__callee__).parameters.select{|param| eval(param.last.to_s) }.collect{|param| [param.last, eval(param.last.to_s)]}]
      response = @connection.PUT("patients/#{patientid}", params, AthenaHealthApiConnector.common_headers)

      raise "HTTP error code encountered: #{response.code}" unless response.code.to_i == 200
    end

    #get a patient's photo in b64 encoded form
    def get_patient_photo(patientid: )
      response = @connection.GET("patients/#{patientid}/photo", {}, AthenaHealthApiConnector.common_headers)

      #404 means the patient does not exist or no photo found
      return nil if response.code.to_i == 404

      raise "HTTP error code encountered: #{response.code}" unless response.code.to_i == 200

      val = JSON.parse(response.body)

      return val[:image.to_s]
    end

    #set a patient's photo in b64 encoded form
    def set_patient_photo(patientid: , image: )

      params = {}
      params[:image] = image

      response = @connection.POST("patients/#{patientid}/photo", params, AthenaHealthApiConnector.common_headers)

      raise "HTTP error code encountered: #{response.code}" unless response.code.to_i == 200
    end

    #delete a patient's photo
    def delete_patient_photo(patientid: )
      response = @connection.DELETE("patients/#{patientid}/photo", {}, AthenaHealthApiConnector.common_headers)

      raise "HTTP error code encountered: #{response.code}" unless response.code.to_i == 200
    end

    def get_patient_allergies(patientid: , departmentid: )

      params = {}
      params[:departmentid] = departmentid

      response = @connection.GET("chart/#{patientid}/allergies", params, AthenaHealthApiConnector.common_headers)

      raise "HTTP error code encountered: #{response.code}" unless response.code.to_i == 200

      val = JSON.parse(response.body)

      return val[:allergies.to_s]
    end

    def get_patient_vitals(patientid: , departmentid: )

      params = {}
      params[:departmentid] = departmentid
      params[:source] = "ENCOUNTER"

      return get_paged(
        url: "chart/#{patientid}/vitals", params: params,
        headers: AthenaHealthApiConnector.common_headers, field: :vitals)
    end

    def get_patient_vaccines(patientid: , departmentid: )

      params = {}
      params[:departmentid] = departmentid

      return get_paged(
        url: "chart/#{patientid}/vaccines", params: params,
        headers: AthenaHealthApiConnector.common_headers, field: :vaccines)
    end

    def get_patient_medications(patientid: , departmentid: )

      params = {}
      params[:departmentid] = departmentid

      response = @connection.GET("chart/#{patientid}/medications", params, AthenaHealthApiConnector.common_headers)

      raise "HTTP error code encountered: #{response.code}" unless response.code.to_i == 200

      val = JSON.parse(response.body)

      #Athena is including each medication in an array.  Removing that extra array here
      val[:medications.to_s].flatten
    end

    def create_patient_insurance(
      patientid: ,
      insuranceidnumber: 'unknown',
      insurancepackageid: ,
      insurancephone: nil,
      insurancepolicyholderaddress1: nil,
      insurancepolicyholderaddress2: nil,
      insurancepolicyholdercity: nil,
      insurancepolicyholdercountrycode: nil,
      insurancepolicyholdercountryiso3166: nil,
      insurancepolicyholderdob: nil,
      insurancepolicyholderfirstname: ,
      insurancepolicyholderlastname: ,
      insurancepolicyholdermiddlename: nil,
      insurancepolicyholdersex: ,
      insurancepolicyholderssn: nil,
      insurancepolicyholderstate: nil,
      insurancepolicyholdersuffix: nil,
      insurancepolicyholderzip: nil,
      policynumber: nil, #group number
      relationshiptoinsuredid: nil,
      sequencenumber: 1, #1=primary, 2=secondary
      updateappointments: nil
      )

      params = Hash[method(__callee__).parameters.select{|param| eval(param.last.to_s) }.collect{|param| [param.last, eval(param.last.to_s)]}]
      response = @connection.POST("patients/#{patientid}/insurances", params, AthenaHealthApiConnector.common_headers)

      raise "HTTP error code encountered: #{response.code}" unless response.code.to_i == 200
    end

    def get_patient_insurances(patientid:)

      params = {}

      return get_paged(
        url: "patients/#{patientid}/insurances", params: params,
        headers: AthenaHealthApiConnector.common_headers, field: :insurances)
    end

    def create_appointment_note(
      appointmentid: ,
      notetext:
      )

      params = Hash[method(__callee__).parameters.select{|param| eval(param.last.to_s) }.collect{|param| [param.last, eval(param.last.to_s)]}]
      response = @connection.POST("appointments/#{appointmentid}/notes", params, AthenaHealthApiConnector.common_headers)

      raise "HTTP error code encountered: #{response.code}" unless response.code.to_i == 200
    end
  end
end
