require "athena_health_api"

module AthenaHealthApiHelper
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
      return future? || checked_in? || checked_out? || charge_entered?
    end

    def pre_checked_in?
      return future? || open? || cancelled?
    end

    def post_checked_in?
      return !pre_checked_in
    end

    def cancelled?
      return @appointmentstatus == "x"
    end

    def checked_in?
      return @appointmentstatus == "2"
    end

    def checked_out?
      return @appointmentstatus == "3"
    end

    def charge_entered?
      return @appointmentstatus == "4"
    end

    def future?
      return @appointmentstatus == "f"
    end

    def open?
      return @appointmentstatus == "o"
    end
  end

  class AthenaHealthApiConnector
    #for some reason, gzip encoding returns invalid blocks in failure cases
    #todo: needs more investigation
    @@common_headers = { "Accept-Encoding" => "deflate;q=0.6,identity;q=0.3" }

    def initialize(key: ENV["ATHENA_KEY"], secret: ENV["ATHENA_SECRET"], 
      version: ENV["ATHENA_VERSION"].empty? ? "preview1" : ENV["ATHENA_VERSION"], 
      practice_id: ENV["ATHENA_PRACTICE_ID"].empty? ? "195900" : ENV["ATHENA_PRACTICE_ID"])

      @connection = AthenaHealthAPI::Connection.new(version, key, secret, practice_id)
    end

    # obtain information on an athena appointment
    # returns an instance of AthenaStruct, nil of not found
    # raises exceptions if anything goes wrong
    def get_appointment(practiceid: @@practiceid_default, 
      appointmentid: , showinsurance: false)

      params = {}
      params[:showinsurance] = showinsurance

      response = @connection.GET("appointments/#{appointmentid}", params, @@common_headers)

      #410 means the appointment does not exist
      return nil if response.code.to_i == 410

      raise "response.code #{reponse.code}" unless response.code.to_i == 200

      return AthenaStruct.new(JSON.parse(response.body)[0])
    end

    # delete an open appointment
    # no return value
    # raises exceptions if anything goes wrong
    def delete_appointment(appointmentid: )
      params = {}

      response = @connection.DELETE("appointments/#{appointmentid}", params, @@common_headers)

      raise "response.code #{reponse.code}" unless response.code.to_i == 200
    end

    # create open appointment in athena
    # returns the id of the newly created appointment
    # raises exceptions if anything goes wrong in the process
    def create_appointment(appointmentdate: , appointmenttime:, 
      appointmenttypeid: nil, departmentid: , providerid: , reasonid: nil)

      params = {}
      params[:appointmentdate] = appointmentdate
      params[:appointmenttime] = appointmenttime
      params[:appointmenttypeid] = appointmenttypeid if appointmenttypeid
      params[:departmentid] = departmentid
      params[:providerid] = providerid
      params[:reasonid] = reasonid if reasonid

      response = @connection.POST("appointments/open", params, @@common_headers)

      raise "response.code #{reponse.code}" unless response.code.to_i == 200

      val = JSON.parse(response.body)

      raise "unexpected size of appointmentids encountered" unless val[:appointmentids.to_s].length != 1

      return val[:appointmentids.to_s][0].to_i
    end

    # books an appointment slot for a specified patient
    # An open appointment must already exist.
    # raises exceptions if anything goes wrong in the process
    def book_appointment(appointmentid: ,
      appointmenttypeid: nil, bookingnote: nil, departmentid: nil, ignoreschedulablepermission: true,
      insurancecompany: nil, insurancegroupid: nil, insuranceidnumber: nil, insurancenote: nil,
      insurancephone: nil, insuranceplanname: nil, insurancepolicyholder: nil, nopatientcase: false,
      patientid: , patientrelationshiptopolicyholder: nil, reasonid: nil)

      params = {}
      params[:appointmenttypeid] = appointmenttypeid if appointmenttypeid
      params[:bookingnote] = bookingnote if bookingnote
      params[:departmentid] = departmentid
      params[:ignoreschedulablepermission] = ignoreschedulablepermission
      params[:insurancecompany] = insurancecompany if insurancecompany
      params[:insurancegroupid] = insurancegroupid if insurancegroupid
      params[:insuranceidnumber] = insuranceidnumber if insuranceidnumber
      params[:insurancenote] = insurancenote if insurancenote
      params[:insurancephone] = insurancephone if insurancephone
      params[:insuranceplanname] = insuranceplanname if insuranceplanname
      params[:insurancepolicyholder] = insurancepolicyholder if insurancepolicyholder
      params[:nopatientcase] = nopatientcase
      params[:patientid] = patientid
      params[:patientrelationshiptopolicyholder] = patientrelationshiptopolicyholder if patientrelationshiptopolicyholder
      params[:reasonid] = reasonid if reasonid

      response = @connection.PUT("appointments/#{appointmentid}", params, @@common_headers)

      raise "response.code #{reponse.code}" unless response.code.to_i == 200
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

      response = @connection.PUT("appointments/#{appointmentid}/cancel", params, @@common_headers)

      raise "response.code #{reponse.code}" unless response.code.to_i == 200
    end

    # cancel a booked appointment
    # A booked appointment must already exist.
    # raises exceptions if anything goes wrong in the process
    def reschedule_appointment(appointmentid: ,
      ignoreschedulablepermission: true, newappointmentid: , nopatientcase: false, patientid: ,
      reasonid: nil, reschedulereason: nil)

      params = {}
      params[:ignoreschedulablepermission] = ignoreschedulablepermission
      params[:newappointmentid] = newappointmentid
      params[:nopatientcase] = nopatientcase
      params[:patientid] = patientid
      params[:reasonid] = reasonid if reasonid
      params[:reschedulereason] = reschedulereason if reschedulereason

      response = @connection.PUT("appointments/#{appointmentid}/reschedule", params, @@common_headers)

      raise "response.code #{reponse.code}" unless response.code.to_i == 200
    end

    # freezes/unfreezes an appointment
    def freeze_appointment(appointmentid:, freeze: true)

      params = {}
      params[:appointmentid] = appointmentid
      params[:freeze] = freeze.to_s

      response = @connection.PUT("appointments/#{appointmentid}/freeze", params, @@common_headers)

      raise "response.code #{reponse.code}" unless response.code.to_i == 200
    end

    # create open appointment in athena
    # returns the id of the newly created appointment
    # raises exceptions if anything goes wrong in the process
    def checkin_appointment(appointmentid:)

      params = {}
      params[:appointmentid] = appointmentid

      response = @connection.POST("appointments/#{appointmentid}/checkin", params, @@common_headers)

      raise "response.code #{reponse.code}" unless response.code.to_i == 200
    end

    # recursive function for retrieving a full dataset thorugh multiple GET calls.
    # returns an array of AthenaStructs
    # raises exceptions if anything goes wrong in the process
    def get_paged(url: , params: , headers: , field: , offset: 0, limit: 5000)
      raise "limit #{limit} is higher then max allowed 5000." if limit > 5000

      local_params = params.clone
      local_params['offset'] = offset
      local_params['limit'] = limit

      response = @connection.GET(url, local_params, headers)

      raise "response.code #{response.code}" unless response.code.to_i == 200

      parsed = JSON.parse(response.body)

      entries = []

      parsed[field.to_s].each do | val |
        entries.push AthenaStruct.new val
      end

      #add following pages of results
      if parsed[:next.to_s]
        entries.concat(
          get_paged(url: url,
            params: params, headers: headers, field: field, offset: offset + limit, 
            limit: limit))
      end

      return entries
    end

    # get a list of available appointment types
    # returns an array of AthenaStructs
    # raises exceptions if anything goes wrong in the process
    def get_appointment_types(hidegeneric: false, 
      hidenongeneric: false, hidenonpatient: false, hidetemplatetypeonly: true, limit: 5000)

      params = {}
      params[:hidegeneric] = hidegeneric
      params[:hidenongeneric] = hidenongeneric
      params[:hidenonpatient] = hidenonpatient
      params[:hidetemplatetypeonly] = hidetemplatetypeonly

      return get_paged(
        url: "/appointmenttypes", params: params, 
        headers: @@common_headers, field: :appointmenttypes, limit: limit)
    end

    # get a list of available appointment reasons
    # returns an array of AthenaStructs
    # raises exceptions if anything goes wrong in the process
    # todo: do we need separate calls for existing vs new patients
    def get_appointment_reasons(departmentid: , 
      providerid: , limit: 5000)

      params = {}
      params[:departmentid] = departmentid
      params[:providerid] = providerid

      return get_paged(
        url: "/patientappointmentreasons", params: params, 
        headers: @@common_headers, field: :patientappointmentreasons, limit: limit)
    end

    # get a list of open appointments
    # returns an array of AthenaStructs
    # raises exceptions if anything goes wrong in the process
    def get_open_appointments(
      appointmenttypeid: nil, bypassscheduletimechecks: true, departmentid:, enddate: nil,
      ignoreschedulablepermission: true, providerid: nil, reasonid: nil, showfrozenslots: false,
      startdate: nil, limit: 5000)

      params = {}
      params[:appointmenttypeid] = appointmenttypeid if appointmenttypeid
      params[:bypassscheduletimechecks] = bypassscheduletimechecks
      params[:departmentid] = departmentid
      params[:enddate] = enddate if enddate
      params[:ignoreschedulablepermission] = ignoreschedulablepermission
      params[:providerid] = providerid if providerid
      params[:reasonid] = reasonid if reasonid
      params[:showfrozenslots] = showfrozenslots
      params[:startdate] = startdate if startdate

      return get_paged(
        url: "/appointments/open", params: params, 
        headers: @@common_headers, field: :appointments, limit: limit)
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

      params = {}
      params[:appointmenttypeid] = appointmenttypeid if appointmenttypeid
      params[:departmentid] = departmentid
      params[:enddate] = enddate
      params[:endlastmodified] = endlastmodified if endlastmodified
      params[:ignorerestrictions] = ignorerestrictions
      params[:patientid] = patientid if patientid
      params[:providerid] = providerid if providerid
      params[:scheduledenddate] = scheduledenddate if scheduledenddate
      params[:scheduledstartdate] = scheduledstartdate if scheduledstartdate
      params[:showcancelled] = showcancelled
      params[:showclaimdetail] = showclaimdetail
      params[:showcopay] = showcopay
      params[:showinsurance] = showinsurance
      params[:showpatientdetail] = showpatientdetail
      params[:startdate] = startdate
      params[:startlastmodified] = startlastmodified if startlastmodified

      return get_paged(
        url: "/appointments/booked", params: params, 
        headers: @@common_headers, field: :appointments, limit: limit)
    end
  end

  class MockConnector
    @@appointment_types_default = [{
        "shortname": "A20",
        "name": "ANY 20",
        "duration": "20",
        "patientdisplayname": "ANY 20",
        "appointmenttypeid": "1",
        "generic": "true",
        "patient": "true",
        "templatetypeonly": "true"
    }, {
        "shortname": "WC",
        "name": "WELL CHILD",
        "duration": "40",
        "patientdisplayname": "WELL CHILD",
        "appointmenttypeid": "21",
        "generic": "false",
        "patient": "true",
        "templatetypeonly": "false"
    }, {
        "shortname": "PROB",
        "name": "PROBLEM",
        "duration": "20",
        "patientdisplayname": "PROBLEM",
        "appointmenttypeid": "23",
        "generic": "false",
        "patient": "true",
        "templatetypeonly": "false"
    }, {
        "shortname": "VANU",
        "name": "VACCINE\/NURSE ONLY",
        "duration": "20",
        "patientdisplayname": "VACCINE\/NURSE ONLY",
        "appointmenttypeid": "22",
        "generic": "false",
        "patient": "true",
        "templatetypeonly": "false"
    }]

    def self.structize(parsed)
      entries = []

      parsed.each do | val |
        entries.push AthenaStruct.new val
      end

      return entries
    end

    def initialize(appointment_types: @@appointment_types_default, appointments: [], appointment_resons: [])
      @appointment_types = MockConnector.structize(JSON.parse(appointment_types.to_json))
      @appointments = MockConnector.structize(JSON.parse(appointments.to_json))
      @appointment_resons = MockConnector.structize(JSON.parse(appointment_resons.to_json))
    end

    def get_appointment(appointmentid: , showinsurance: false)
      matching = @appointments.select { |appt| appt.appointmentid == appointmentid }
      return nil if matching.empty?
      return matching.first
    end

    def delete_appointment(appointmentid: )
      appt = get_appointment(appointmentid: appointmentid)
      raise "Could not find appointment appt=#{appt.to_json}" if appt.nil?
      raise "Cannot delete non-open appointment appt=#{appt.to_json}" unless appt.open?
      @appointments.delete_if { |appt| appt.appointmentid == appointmentid }
    end

    def next_id()
      id = 1

      @appointments.each do |appt|
        id = app.appointmentid if appt.appointmentid > id
      end

      return id + 1
    end

    def create_appointment(
      appointmentdate: , appointmenttime:, appointmenttypeid: nil, departmentid: ,
      providerid: , reasonid: nil)

      #validate params
      Date.strptime(appointmentdate, "%m/%d/%Y")
      DateTime.strptime(appointmenttime, "%H:%M")
      raise "Invalid departmentid: #{departmentid}" if departmentid.to_i <= 0
      raise "Invalid providerid: #{providerid}" if providerid.to_i <= 0

      id = next_id()

      @appointments.push AthenaStruct.new({ 
        :appointmentid => next_id(), 
        :date => appointmentdate,
        :starttime => appointmenttime,
        :appointmenttypeid => appointmenttypeid,
        :departmentid => departmentid,
        :reasonid => reasonid,
        :appointmentstatus => "o",
        :frozenyn => false
        })

      return id
    end

    def book_appointment(appointmentid: ,
      appointmenttypeid: nil, bookingnote: nil, departmentid: nil, ignoreschedulablepermission: true,
      insurancecompany: nil, insurancegroupid: nil, insuranceidnumber: nil, insurancenote: nil,
      insurancephone: nil, insuranceplanname: nil, insurancepolicyholder: nil, nopatientcase: false,
      patientid: , patientrelationshiptopolicyholder: nil, reasonid: nil)

      #validate params
      raise "Invalid patientid: #{patientid}" if patientid.to_i <= 0

      appt = get_appointment(appointmentid: appointmentid)
      raise "Could not find appointment id=#{appointmentid}" if appt.nil?
      raise "Appointment appt=#{appt.to_json} is not open" unless appt.open?
      raise "Appointment appt=#{appt.to_json} is frozen" if appt.frozenyn
      appt.appointmentstatus = "f"
      appt.add_field(:patientid, patientid)
    end

    def cancel_appointment(appointmentid: ,
      cancellationreason: nil, ignoreschedulablepermission: true, nopatientcase: false, patientid: )

      #validate params
      raise "Invalid patientid: #{patientid}" if patientid.to_i <= 0

      appt = get_appointment(appointmentid: appointmentid)
      raise "Could not find appointment id=#{appointmentid}" if appt.nil?
      raise "Appointment appt=#{appt.to_json} is not booked" unless appt.booked?
      appt.appointmentstatus = "x"
    end

    def freeze_appointment(appointmentid:, freeze:)
      appt = get_appointment(appointmentid: appointmentid)
      raise "Could not find appointment id=#{appointmentid}" if appt.nil?
      appt.frozenyn = freeze
    end

    def checkin_appointment(appointmentid:)
      appt = get_appointment(appointmentid: appointmentid)
      raise "Could not find appointment id=#{appointmentid}" if appt.nil?
      raise "Appointment appt=#{appt.to_json} is not future" unless appt.future?
      appt.appointmentstatus = "2"
    end

    def get_appointment_types(hidegeneric: false, 
      hidenongeneric: false, hidenonpatient: false, hidetemplatetypeonly: true, limit: 5000)

      return @appointment_types
    end

    def get_appointment_reasons(departmentid: , 
      providerid: , limit: 5000)

      return @appointment_resons
    end

    def get_open_appointments(
      appointmenttypeid: nil, bypassscheduletimechecks: true, departmentid:, enddate: nil,
      ignoreschedulablepermission: true, providerid: nil, reasonid: nil, showfrozenslots: false,
      startdate: nil, limit: 5000)

      #validate params
      raise "Invalid departmentid: #{departmentid}" if departmentid.to_i <= 0
      raise "Invalid departmentid: #{providerid}" if providerid && providerid.to_i <= 0

      return @appointments.select { |appt| appt.open? && (showfrozenslots || !appt.frozenyn)}
    end

    def get_booked_appointments(
      appointmenttypeid: nil, departmentid: , enddate: , endlastmodified: nil,
      ignorerestrictions: true, patientid: nil, providerid: nil, scheduledenddate: nil,
      scheduledstartdate: nil, showcancelled: true, showclaimdetail: false, showcopay: true,
      showinsurance: false, showpatientdetail: false, startdate:, startlastmodified: nil, 
      limit: 5000)

      #validate params
      raise "Invalid departmentid: #{departmentid}" if departmentid.to_i <= 0
      raise "Invalid departmentid: #{providerid}" if providerid && providerid.to_i <= 0

      #todo: add time filtering

      return @appointments.select { |appt| appt.booked? }
    end
  end
end
