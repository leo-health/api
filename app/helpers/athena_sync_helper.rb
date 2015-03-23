require "athena_health_api"

module AthenaSyncHelper
  @@version = ENV["ATHENA_VERSION"]
  @@key = ENV["ATHENA_KEY"]
  @@secret = ENV["ATHENA_SECRET"]
  @@practice_id_default = ENV["ATHENA_PRACTICE_ID"]

  #for some reason, gzip encoding returns invalid blocks in failure cases
  #todo: needs more investigation
  @@common_headers = { "Accept-Encoding" => "deflate;q=0.6,identity;q=0.3" }

  def self.get_paged(connection: nil, practiceid:, url: , params: , headers: , field: , offset: 0, limit: 1000)
    connection = AthenahealthAPI::Connection.new(@@version, @@key, @@secret, practiceid) unless connection

    local_params = params.clone
    local_params['offset'] = offset
    local_params['limit'] = limit

    res = connection.GET(url, local_params, headers)
    if res.code != "200" || res.value.class != Hash
      Rails.logger.error "AthenaSyncHelper: invalid response #{res.to_json}"
      return nil
    end

    entries = res.value[field.to_s]

    entries.concat(get_paged(connection: connection, practiceid: practiceid, url: url,
      params: params, headers: headers, field: field, offset: offset + limit, limit: limit)) if res.value[:next.to_s]

    return entries
  end

  def self.get_appointmenttypes(practiceid: practice_id_default, hidegeneric: false, 
    hidenongeneric: false, hidenonpatient: true, hidetemplatetypeonly: true, limit: nil)

    params = {}
    params[:hidegeneric] = hidegeneric
    params[:hidenongeneric] = hidenongeneric
    params[:hidenonpatient] = hidenonpatient
    params[:hidetemplatetypeonly] = hidetemplatetypeonly

    return get_paged(
      practiceid: practiceid, url: "/appointmenttypes", params: params, 
      headers: @@common_headers, field: :appointmenttypes, limit: limit)
  end

#existingpatient
#newpatient
  def self.get_appointmentreasons(practiceid: practice_id_default, departmentid: , 
    providerid: , limit: nil)

    params = {}
    params[:departmentid] = departmentid
    params[:providerid] = providerid

    return get_paged(
      practiceid: practiceid, url: "/patientappointmentreasons", params: params, 
      headers: @@common_headers, field: :patientappointmentreasons, limit: limit)
  end

  def self.get_open_appointments(practice_id: practice_id_default, 
    appointmenttypeid: nil, bypassscheduletimechecks: true, departmentid:, enddate:,
    ignoreschedulablepermission: false, providerid:, reasonid: -1, showfrozenslots: false,
    startdate: ,limit: 1000)

    params = {}
    params[:appointmenttypeid] = appointmenttypeid if appointmenttypeid
    params[:bypassscheduletimechecks] = bypassscheduletimechecks
    params[:department_id] = department_id
    params[:enddate] = enddate
    params[:ignoreschedulablepermission] = ignoreschedulablepermission
    params[:providerid] = providerid
    params[:reasonid] = reasonid
    params[:showfrozenslots] = showfrozenslots
    params[:startdate] = startdate

    return get_paged(
      practiceid: practiceid, url: "/appointments/open", params: params, 
      headers: @@common_headers, field: :appointments, limit: limit)
  end

  #Specifies a provider, department, and date/time for a new appointment slot. 
  def self.post_open_appointment(practice_id: practice_id_default, 
    appointmentdate: , appointmenttime:, appointmenttypeid: nil, departmentid: ,
    providerid: , reasonid: nil)

    connection = AthenahealthAPI::Connection.new(@@version, @@key, @@secret, practice_id)

    params = {}
    params[:appointmentdate] = appointmentdate
    params[:appointmenttime] = appointmenttime
    params[:appointmenttypeid] = appointmenttypeid if appointmenttypeid
    params[:departmentid] = departmentid
    params[:providerid] = providerid
    params[:reasonid] = reasonid if reasonid

    res = connection.POST("appointments/open", params, @@common_headers)

    if res.code != "200" || res.value.class != Hash
      Rails.logger.error "AthenaSyncHelper: invalid response #{res.to_json}"
      return nil
    end

    return res.value['appointmentids']
  end

  def self.get_appointment(practice_id: practice_id_default, 
    appointmentid: , showinsurance: false)

    connection = AthenahealthAPI::Connection.new(@@version, @@key, @@secret, practice_id)

    params = {}
    params[:showinsurance] = showinsurance

    res = connection.GET("appointments/#{appointmentid}", params, @@common_headers)

    if res.code != "200" || res.value.class != Array
      Rails.logger.error "AthenaSyncHelper: invalid response #{res.to_json}"
      return nil
    end

    return res.value[0]
  end

  #Books an appointment slot for a specified patient.
  def self.put_appointment(practice_id: practice_id_default, appointmentid: ,
    appointmenttypeid: nil, bookingnote: nil, departmentid: , ignoreschedulablepermission: false,
    insurancecompany: nil, insurancegroupid: nil, insuranceidnumber: nil, insurancenote: nil,
    insurancephone: nil, insuranceplanname: nil, insurancepolicyholder: nil, nopatientcase: false,
    patientid: , patientrelationshiptopolicyholder: nil, reasonid: nil)
  end

  def self.get_booked_appointments(practice_id: practice_id_default, 
    appointmenttypeid: nil, departmentid: , enddate: , endlastmodified: nil,
    ignorerestrictions: false, patientid: nil, providerid: nil, scheduledenddate: nil,
    scheduledstartdate: nil, showcancelled: false, showclaimdetail: false, showcopay: true,
    showinsurance: false, showpatientdetail: false, startdate:, startlastmodified:, 
    limit: 1000)
    connection = AthenahealthAPI::Connection.new(@@version, @@key, @@secret, practice_id)

    params = {}
    params[:appointmenttypeid] = appointmenttypeid if appointmenttypeid
    params[:departmentid] = department_id
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
    params[:startlastmodified] = startlastmodified

    return get_paged(
      practiceid: practiceid, url: "/appointments/booked", params: params, 
      headers: @@common_headers, field: :appointments, limit: limit)
  end
end
