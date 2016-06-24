require "athena_health_api"

# TODO: single responsibility - get paged should not parse json?

module AthenaHealthApiHelper
  def self.to_datetime(athena_date, athena_time)
    date = Date.strptime(athena_date, '%m/%d/%Y')
    Time.zone.parse("#{date.to_s} #{athena_time}").to_datetime
  end

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
    include Singleton

    attr_reader :connection, :common_headers

    def initialize
      @common_headers = { "Accept-Encoding" => "deflate;q=0.6,identity;q=0.3" }
      @connection = AthenaHealthAPI::Connection.new(*(ENV.values_at "ATHENA_VERSION", "ATHENA_KEY", "ATHENA_SECRET", "ATHENA_PRACTICE_ID"))
    end

    def get(path: , params: {})
      connection.GET(path, params, common_headers)
    end

    def put(path: , params: {})
      connection.PUT(path, params, common_headers)
    end

    def post(path: , params: {})
      connection.POST(path, params, common_headers)
    end

    def delete(path: , params: {})
      connection.DELETE(path, params, common_headers)
    end

    # obtain information on an athena appointment
    # returns an instance of AthenaStruct, nil of not found
    # raises exceptions if anything goes wrong
    def get_appointment(appointmentid: , showinsurance: false)
      params = {showinsurance: showinsurance}
      endpoint = "appointments/#{appointmentid}"
      response = @connection.GET(endpoint, params, common_headers)
      #410 means the appointment does not exist
      return nil if response.code.to_i == 410
      raise "HTTP error for endpoint #{endpoint} code encountered: #{response.code}" unless response.code.to_i == 200
      AthenaStruct.new(JSON.parse(response.body)[0])
    end

    # delete an open appointment
    # no return value
    # raises exceptions if anything goes wrong
    def delete_appointment(appointmentid)
      endpoint = "appointments/#{appointmentid}"
      response = @connection.DELETE(endpoint, {}, common_headers)
      raise "HTTP error for endpoint #{endpoint} code encountered: #{response.code}" unless response.code.to_i == 200
    end

    # create open appointment in athena
    # returns the id of the newly created appointment
    # raises exceptions if anything goes wrong in the process

    def create_appointment(appointmentdate: , appointmenttime:,
      appointmenttypeid: nil, departmentid: , providerid: , reasonid: nil)

      params = Hash[method(__callee__).parameters.select{|param| eval(param.last.to_s) }.collect{|param| [param.last, eval(param.last.to_s)]}]
      endpoint = "appointments/open"
      response = @connection.POST(endpoint, params, common_headers)
      raise "HTTP error for endpoint #{endpoint} code encountered: #{response.code}" unless response.code.to_i == 200
      val = JSON.parse(response.body)
      raise "unexpected size of appointmentids encountered: #{val[:appointmentids.to_s].length}" unless val[:appointmentids.to_s].length == 1
      val[:appointmentids.to_s].keys[0].to_i
    end

    # books an appointment slot for a specified patient
    # An open appointment must already exist.
    # raises exceptions if anything goes wrong in the process
    def book_appointment(appointmentid: ,
      appointmenttypeid: nil, bookingnote: nil, departmentid: nil, ignoreschedulablepermission: true,
      insurancecompany: nil, insurancegroupid: nil, insuranceidnumber: nil, insurancenote: nil,
      insurancephone: nil, insuranceplanname: nil, insurancepolicyholder: nil, nopatientcase: false,
      patientid: , patientrelationshiptopolicyholder: nil, reasonid: nil)

      endpoint = "appointments/#{appointmentid}"
      params = Hash[method(__callee__).parameters.select{|param| eval(param.last.to_s) }.collect{|param| [param.last, eval(param.last.to_s)]}]
      response = @connection.PUT(endpoint, params, common_headers)
      raise "HTTP error for endpoint #{endpoint} code encountered: #{response.code}" unless response.code.to_i == 200
      AthenaStruct.new JSON.parse(response.body).first
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

      endpoint = "appointments/#{appointmentid}/cancel"
      response = @connection.PUT(endpoint, params, common_headers)

      raise "HTTP error for endpoint #{endpoint} code encountered: #{response.code}" unless response.code.to_i == 200
    end

    # reschedule a booked appointment
    # A booked appointment must already exist.
    # raises exceptions if anything goes wrong in the process
    def reschedule_appointment(appointmentid: ,
      ignoreschedulablepermission: true, newappointmentid: , nopatientcase: false, patientid: ,
      reasonid: nil, reschedulereason: nil)

      endpoint = "appointments/#{appointmentid}/reschedule"
      params = Hash[method(__callee__).parameters.select{|param| eval(param.last.to_s) }.collect{|param| [param.last, eval(param.last.to_s)]}]
      response = @connection.PUT(endpoint, params, common_headers)

      raise "HTTP error for endpoint #{endpoint} code encountered: #{response.code}" unless response.code.to_i == 200
    end

    # freezes/unfreezes an appointment
    def freeze_appointment(appointmentid:, freeze: true)
      params = Hash[method(__callee__).parameters.select{|param| eval(param.last.to_s) }.collect{|param| [param.last, eval(param.last.to_s)]}]
      endpoint = "appointments/#{appointmentid}/freeze"
      response = @connection.PUT(endpoint, params, common_headers)

      raise "HTTP error for endpoint #{endpoint} code encountered: #{response.code}" unless response.code.to_i == 200
    end

    # create open appointment in athena
    # returns the id of the newly created appointment
    # raises exceptions if anything goes wrong in the process
    def checkin_appointment(appointmentid:)
      params = {}
      params[:appointmentid] = appointmentid
      endpoint = "appointments/#{appointmentid}/checkin"
      response = @connection.POST(endpoint, params, common_headers)
      raise "HTTP error for endpoint #{endpoint} code encountered: #{response.code}" unless response.code.to_i == 200
    end


    # recursive function for retrieving a full dataset thorugh multiple GET calls.
    # returns an array of AthenaStructs
    # raises exceptions if anything goes wrong in the process
    def get_paged(url: , params: {}, headers: , field: , limit: nil, page_size: nil, structize: false, version_and_practice_prepended: false)
      params = params.symbolize_keys
      limit ||= params[:limit] || Float::INFINITY # By default, get all pages
      params[:limit] = page_size if page_size
      response = @connection.GET(url, params, headers, version_and_practice_prepended)

      raise "HTTP error for endpoint #{url} code encountered: #{response.code}" unless response.code.to_i == 200
      parsed = JSON.parse(response.body)
      entries = parsed[field.to_s] || []
      entries = entries.map { |val| AthenaStruct.new val } if structize

      #add following pages of results
      num_entries_still_needed = limit - entries.size
      next_page_url = parsed["next"]

      if next_page_url && num_entries_still_needed > 0
        next_page_url = next_page_url.split("/").from(3).join("/") # Athena responds with /v1 regardless of the original url passed /preview1
        entries += get_paged(url: next_page_url, headers: headers, field: field, limit: num_entries_still_needed, structize: structize, version_and_practice_prepended: true)
      end

      limit < Float::INFINITY ? entries[0...limit] : entries
    end

    # get a list of available appointment types
    # returns an array of AthenaStructs
    # raises exceptions if anything goes wrong in the process
    def get_appointment_types(hidegeneric: false,
      hidenongeneric: false, hidenonpatient: false, hidetemplatetypeonly: true)

      params = Hash[method(__callee__).parameters.select{|param| eval(param.last.to_s) }.collect{|param| [param.last, eval(param.last.to_s)]}]

      return get_paged(
        url: "/appointmenttypes", params: params,
        headers: common_headers, field: :appointmenttypes)
    end

    # get a list of available appointment reasons
    # returns an array of AthenaStructs
    # raises exceptions if anything goes wrong in the process
    # todo: do we need separate calls for existing vs new patients
    def get_appointment_reasons(departmentid: ,
      providerid:)

      params = Hash[method(__callee__).parameters.select{|param| eval(param.last.to_s) }.collect{|param| [param.last, eval(param.last.to_s)]}]

      return get_paged(
        url: "/patientappointmentreasons", params: params,
        headers: common_headers, field: :patientappointmentreasons)
    end

    # get a list of open appointments
    # returns an array of AthenaStructs
    # raises exceptions if anything goes wrong in the process
    def get_open_appointments(
      appointmenttypeid: nil, bypassscheduletimechecks: true, departmentid:, enddate: nil,
      ignoreschedulablepermission: true, providerid: nil, reasonid: nil, showfrozenslots: false,
      startdate: nil)

      params = Hash[method(__callee__).parameters.select{|param| eval(param.last.to_s) }.collect{|param| [param.last, eval(param.last.to_s)]}]

      return get_paged(
        url: "/appointments/open", params: params,
        headers: common_headers, field: :appointments, structize: true)
    end

    # get a list of booked appointments
    # returns an array of AthenaStructs
    # raises exceptions if anything goes wrong in the process
    def get_booked_appointments(
      appointmenttypeid: nil, departmentid: , enddate: , endlastmodified: nil,
      ignorerestrictions: true, patientid: nil, providerid: nil, scheduledenddate: nil,
      scheduledstartdate: nil, showcancelled: true, showclaimdetail: false, showcopay: true,
      showinsurance: false, showpatientdetail: false, startdate:, startlastmodified: nil)

      params = Hash[method(__callee__).parameters.select{|param| eval(param.last.to_s) }.collect{|param| [param.last, eval(param.last.to_s)]}]

      return get_paged(
        url: "/appointments/booked", params: params,
        headers: common_headers, field: :appointments, structize: true)
    end

    #Get list of all patients: GET /preview1/:practiceid/patients
    def get_patients(departmentid:, limit: nil)
      params = Hash[method(__callee__).parameters.select{|param| eval(param.last.to_s) }.collect{|param| [param.last, eval(param.last.to_s)]}]
      start = Time.now
      entries = get_paged(
        url: "patients",
        params: params,
        headers: common_headers,
        field: :patients,
        page_size: 100,
        limit: limit
      )
      puts "Request time: #{Time.now - start}"
      entries
    end

    #Create a patient: POST /preview1/:practiceid/patients
    #returns patient id
    #TODO: Doesn't seem to create a new patient when some of the records are the same.  Investigate.
    def create_patient(**params)
      endpoint = "patients"
      response = @connection.POST(endpoint, params, common_headers)
      raise "HTTP error for endpoint #{endpoint} code encountered: #{response.code}" unless response.code.to_i == 200
      val = JSON.parse(response.body)
      raise "unexpected patient list len: #{val.length}" unless val.length == 1
      return val[0][:patientid.to_s].to_i
    end

    #Get a patient: GET /preview1/:practiceid/patients/:patientid
    #returns null if patient does not exist
    def get_patient(patientid: )
      endpoint = "patients/#{patientid}"
      response = @connection.GET(endpoint, {}, common_headers)
      #404 means the patient does not exist
      return nil if response.code.to_i == 404
      raise "HTTP error for endpoint #{endpoint} code encountered: #{response.code}" unless response.code.to_i == 200
      return AthenaStruct.new(JSON.parse(response.body)[0])
    end

    def get_best_match_patient(anyfirstname: nil, anyphone: nil, appointmentdepartmentid: nil, appointmentproviderid: nil,
                               dob: , email: nil, firstname: nil, guarantoremail: nil, guarantorphone: nil, homephone: nil,
                               ignorerestrictions: nil, lastname: , middlename: nil, mobilephone: nil, preferredname: nil,
                               showportalstatus: nil, ssn: nil, suffix: nil, upcomingappointmenthours: nil, workphone: nil,
                               zip: nil)

      params = Hash[method(__callee__).parameters.select{|param| eval(param.last.to_s) }.collect{|param| [param.last, eval(param.last.to_s)]}]
      endpoint = "patients/bestmatch"
      response = @connection.GET(endpoint, params, common_headers)
      raise "HTTP error for endpoint #{endpoint} code encountered: #{response.code}" unless response.code.to_i == 200
      result = JSON.parse(response.body)
      return nil if result.empty?
      return AthenaStruct.new(result[0])
    end

    # NOTE: need to be careful using **kwargs. patientid: is not included in params. Here it's ok since patientid is in the url, not in the query params
    def update_patient(patientid:, **params)
      # patientid: ,
      # status: nil, #active, inactive, prospective, deleted
      # firstname: ,
      # lastname: ,
      # sex: ,
      # dob: ,
      # homephone: nil,
      # guarantormiddlename: nil,
      # guarantorlastname: nil,
      # guarantoraddress1: nil,
      # guarantoraddress2: nil,
      # guarantorstate: nil,
      # guarantorzip: nil,
      # guarantordob: nil,
      # guarantoremail: ,
      # guarantorphone: nil,
      # departmentid: ,
      # guarantorfirstname: nil,
      # guarantorcity: nil,
      # middlename: nil,
      # guarantorssn: nil,
      # guarantorrelationshiptopatient: nil,
      # contactname: nil,
      # contactrelationship: nil,
      # contactmobilephone: nil

      endpoint = "patients/#{patientid}"
      response = @connection.PUT(endpoint, params, common_headers)
      raise "HTTP error for endpoint #{endpoint} code encountered: #{response.code}" unless response.code.to_i == 200
    end

    #get a patient's photo in b64 encoded form
    def get_patient_photo(patientid: )
      endpoint = "patients/#{patientid}/photo"
      response = @connection.GET(endpoint, {}, common_headers)
      #404 means the patient does not exist or no photo found
      return nil if response.code.to_i == 404
      raise "HTTP error for endpoint #{endpoint} code encountered: #{response.code}" unless response.code.to_i == 200
      val = JSON.parse(response.body)
      return val[:image.to_s]
    end

    #set a patient's photo in b64 encoded form
    def set_patient_photo(patientid: , image: )
      params = {}
      params[:image] = image
      endpoint = "patients/#{patientid}/photo"
      response = @connection.POST(endpoint, params, common_headers)
      raise "HTTP error for endpoint #{endpoint} code encountered: #{response.code}" unless response.code.to_i == 200
    end

    #delete a patient's photo
    def delete_patient_photo(patientid: )
      endpoint = "patients/#{patientid}/photo"
      response = @connection.DELETE(endpoint, {}, common_headers)
      raise "HTTP error for endpoint #{endpoint} code encountered: #{response.code}" unless response.code.to_i == 200
    end

    def get_patient_allergies(patientid: , departmentid: )
      params = {}
      params[:departmentid] = departmentid
      endpoint = "chart/#{patientid}/allergies"
      response = @connection.GET(endpoint, params, common_headers)
      raise "HTTP error for endpoint #{endpoint} code encountered: #{response.code}" unless response.code.to_i == 200
      val = JSON.parse(response.body)
      return val[:allergies.to_s]
    end

    def get_patient_vitals(patientid: , departmentid: )
      params = {}
      params[:departmentid] = departmentid
      params[:source] = "ENCOUNTER"
      return get_paged(
        url: "chart/#{patientid}/vitals",
        params: params,
        headers: common_headers,
        field: :vitals
      )
    end

    def get_patient_vaccines(patientid: , departmentid: )
      params = {}
      params[:departmentid] = departmentid
      return get_paged(
        url: "chart/#{patientid}/vaccines",
        params: params,
        headers: common_headers,
        field: :vaccines
      )
    end

    def get_patient_medications(patientid: , departmentid: )
      params = {}
      params[:departmentid] = departmentid
      endpoint = "chart/#{patientid}/medications"
      response = @connection.GET(endpoint, params, common_headers)
      raise "HTTP error for endpoint #{endpoint} code encountered: #{response.code}" unless response.code.to_i == 200
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
      endpoint = "patients/#{patientid}/insurances"
      response = @connection.POST(endpoint, params, common_headers)
      raise "HTTP error for endpoint #{endpoint} code encountered: #{response.code}" unless response.code.to_i == 200
    end

    def get_patient_insurances(patientid:)
      return get_paged(
        url: "patients/#{patientid}/insurances", params: {},
        headers: common_headers, field: :insurances)
    end

    def create_appointment_note(appointmentid: , notetext:)
      params = Hash[method(__callee__).parameters.select{|param| eval(param.last.to_s) }.collect{|param| [param.last, eval(param.last.to_s)]}]
      endpoint = "appointments/#{appointmentid}/notes"
      response = @connection.POST(endpoint, params, common_headers)
      raise "HTTP error for endpoint #{endpoint} code encountered: #{response.code}" unless response.code.to_i == 200
    end

    def get_providers(**params)
      endpoint = "providers"
      get_paged(url: endpoint, params: params, field: :providers, headers: @common_headers)
    end
  end
end
