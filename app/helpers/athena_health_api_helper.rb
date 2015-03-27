require "athena_health_api"

module AthenaHealthApiHelper
  @@version = ENV["ATHENA_VERSION"]
  @@key = ENV["ATHENA_KEY"]
  @@secret = ENV["ATHENA_SECRET"]
  @@practiceid_default = ENV["ATHENA_PRACTICE_ID"]

  #for some reason, gzip encoding returns invalid blocks in failure cases
  #todo: needs more investigation
  @@common_headers = { "Accept-Encoding" => "deflate;q=0.6,identity;q=0.3" }

  class AthenaStuct
    def initialize(args)
      args.each do |k,v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end
    end
  end

  # obtain information on an athena appointment
  # returns an instance of AthenaStuct, nil of not found
  # raises exceptions if anything goes wrong
  def self.get_appointment(practiceid: @@practiceid_default, 
    appointmentid: , showinsurance: false)

    connection ||= AthenahealthAPI::Connection.new(@@version, @@key, @@secret, practiceid)

    params = {}
    params[:showinsurance] = showinsurance

    response = connection.GET("appointments/#{appointmentid}", params, @@common_headers)

    #todo: what is the response code for not finding an appointment
    raise "response.code #{reponse.code}" unless response.code.to_i == 200

    return AthenaStuct.new(JSON.parse(response.body)[0])
  end

  # delete an open appointment
  # no return value
  # raises exceptions if anything goes wrong
  def self.delete_open_appointment(practiceid: @@practiceid_default, appointmentid: )
    connection ||= AthenahealthAPI::Connection.new(@@version, @@key, @@secret, practiceid)

    params = {}

    response = connection.DELETE("appointments/#{appointmentid}", params, @@common_headers)

    #todo: do we need to check response body
    raise "response.code #{reponse.code}" unless response.code.to_i == 200
  end

  # create open appointment in athena
  # returns the id of the newly created appointment
  # raises exceptions if anything goes wrong in the process
  def self.create_open_appointment(practiceid: @@practiceid_default, 
    appointmentdate: , appointmenttime:, appointmenttypeid: nil, departmentid: ,
    providerid: , reasonid: nil)

    connection ||= AthenahealthAPI::Connection.new(@@version, @@key, @@secret, practiceid)

    params = {}
    params[:appointmentdate] = appointmentdate
    params[:appointmenttime] = appointmenttime
    params[:appointmenttypeid] = appointmenttypeid if appointmenttypeid
    params[:departmentid] = departmentid
    params[:providerid] = providerid
    params[:reasonid] = reasonid if reasonid

    response = connection.POST("appointments/open", params, @@common_headers)

    raise "response.code #{reponse.code}" unless response.code.to_i == 200

    val = JSON.parse(response.body)

    raise "unexpected size of appointmentids encountered" unless val[:appointmentids.to_s].length != 1

    return val[:appointmentids.to_s][0].to_i
  end

  # books an appointment slot for a specified patient
  # An open appointment must already exist.
  # raises exceptions if anything goes wrong in the process
  def self.book_open_appointment(practiceid: @@practiceid_default, appointmentid: ,
    appointmenttypeid: nil, bookingnote: nil, departmentid: , ignoreschedulablepermission: true,
    insurancecompany: nil, insurancegroupid: nil, insuranceidnumber: nil, insurancenote: nil,
    insurancephone: nil, insuranceplanname: nil, insurancepolicyholder: nil, nopatientcase: false,
    patientid: , patientrelationshiptopolicyholder: nil, reasonid: nil)

    connection ||= AthenahealthAPI::Connection.new(@@version, @@key, @@secret, practiceid)

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

    response = connection.PUT("appointments/#{appointmentid}", params, @@common_headers)

    #todo: do we need to check response body
    raise "response.code #{reponse.code}" unless response.code.to_i == 200
  end

  # cancel a booked appointment
  # A booked appointment must already exist.
  # raises exceptions if anything goes wrong in the process
  def self.cancel_booked_appointment(practiceid: @@practiceid_default, appointmentid: ,
    cancellationreason: nil, ignoreschedulablepermission: true, nopatientcase: false, patientid: )

    connection = AthenahealthAPI::Connection.new(@@version, @@key, @@secret, practiceid)

    params = {}
    params[:cancellationreason] = cancellationreason if cancellationreason
    params[:ignoreschedulablepermission] = ignoreschedulablepermission
    params[:patientid] = patientid

    response = connection.PUT("appointments/#{appointmentid}/cancel", params, @@common_headers)

    #todo: do we need to check response body
    raise "response.code #{reponse.code}" unless response.code.to_i == 200
  end

  # recursive function for retrieving a full dataset thorugh multiple GET calls.
  # returns an array of AthenaStucts
  # raises exceptions if anything goes wrong in the process
  def self.get_paged(connection: nil, practiceid:, url: , params: , headers: , field: , offset: 0, limit: 1000)
    raise "limit #{limit} is higher then max allowed 5000." if limit > 5000

    connection ||= AthenahealthAPI::Connection.new(@@version, @@key, @@secret, practiceid)

    local_params = params.clone
    local_params['offset'] = offset
    local_params['limit'] = limit

    response = connection.GET(url, local_params, headers)

    raise "response.code #{response.code}" unless response.code.to_i == 200

    parsed = JSON.parse(response.body)

    entries = []

    parsed[field.to_s].each do | val |
      entries.push AthenaStuct.new val
    end

    #add following pages of results
    if parsed[:next.to_s]
      entries.concat(
        get_paged(connection: connection, practiceid: practiceid, url: url,
          params: params, headers: headers, field: field, offset: offset + limit, 
          limit: limit))
    end

    return entries
  end

  # get a list of available appointment types
  # returns an array of AthenaStucts
  # raises exceptions if anything goes wrong in the process
  def self.get_appointment_types(practiceid: @@practiceid_default, hidegeneric: false, 
    hidenongeneric: false, hidenonpatient: false, hidetemplatetypeonly: true, limit: 1000)

    params = {}
    params[:hidegeneric] = hidegeneric
    params[:hidenongeneric] = hidenongeneric
    params[:hidenonpatient] = hidenonpatient
    params[:hidetemplatetypeonly] = hidetemplatetypeonly

    return get_paged(
      practiceid: practiceid, url: "/appointmenttypes", params: params, 
      headers: @@common_headers, field: :appointmenttypes, limit: limit)
  end

  # get a list of available appointment reasons
  # returns an array of AthenaStucts
  # raises exceptions if anything goes wrong in the process
  # todo: do we need separate calls for existing vs new patients
  def self.get_appointment_reasons(practiceid: @@practiceid_default, departmentid: , 
    providerid: , limit: 1000)

    params = {}
    params[:departmentid] = departmentid
    params[:providerid] = providerid

    return get_paged(
      practiceid: practiceid, url: "/patientappointmentreasons", params: params, 
      headers: @@common_headers, field: :patientappointmentreasons, limit: limit)
  end

  # get a list of open appointments
  # returns an array of AthenaStucts
  # raises exceptions if anything goes wrong in the process
  def self.get_open_appointments(practiceid: @@practiceid_default, 
    appointmenttypeid: nil, bypassscheduletimechecks: true, departmentid:, enddate: nil,
    ignoreschedulablepermission: true, providerid: nil, reasonid: nil, showfrozenslots: false,
    startdate: nil, limit: 1000)

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
      practiceid: practiceid, url: "/appointments/open", params: params, 
      headers: @@common_headers, field: :appointments, limit: limit)
  end

  # get a list of booked appointments
  # returns an array of AthenaStucts
  # raises exceptions if anything goes wrong in the process
  def self.get_booked_appointments(practiceid: @@practiceid_default, 
    appointmenttypeid: nil, departmentid: , enddate: , endlastmodified: nil,
    ignorerestrictions: true, patientid: nil, providerid: nil, scheduledenddate: nil,
    scheduledstartdate: nil, showcancelled: true, showclaimdetail: false, showcopay: true,
    showinsurance: false, showpatientdetail: false, startdate:, startlastmodified: nil, 
    limit: 1000)
    connection = AthenahealthAPI::Connection.new(@@version, @@key, @@secret, practiceid)

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
      practiceid: practiceid, url: "/appointments/booked", params: params, 
      headers: @@common_headers, field: :appointments, limit: limit)
  end
end
