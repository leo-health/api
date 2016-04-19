class AthenaPracticeSyncService < AthenaSyncService

  def sync_practices(athena_practice_id)
    departments = @connector.get_departments(practiceid: athena_practice_id)
    existing_practices = Practice.where(athena_id: departments.map {|dep| dep["departmentid"]})
    departments.map { |department|
      practice = existing_practices.find_by(athena_id: department["departmentid"])
      practice ||= create_leo_practice(department)
    }
  end

  def sync_providers(practice)
    athena_providers = @connector.get_providers(departmentid: practice.athena_id).sort_by(&method(:get_athena_id))
    existing_providers = ProviderSyncProfile.where(athena_id: athena_providers.map(&method(:get_athena_id))).order(:athena_id).to_enum

    existing_provider = nil
    athena_providers.map { |athena_provider|
      leo_provider = nil

      # get the next existing provider if needed
      begin
        existing_provider ||= existing_providers.next
      rescue StopIteration
      end

      if existing_provider && existing_provider.athena_id == get_athena_id(athena_provider)
        leo_provider = existing_provider
        existing_provider = nil
      end

      update_or_create_leo_provider(leo_provider, athena_provider, practice)
    }
  end

  private


  # PRACTICES

  def update_or_create_leo_practice(leo_practice, athena_department)
    # For the time being, don't update the practice if it already exists.
    # The purpose of this is to not override the seed data for Flatiron Pediatrics.
    # To refactor this will be part of a larger solution involving multiple real practices
    return leo_practice if leo_practice
    create_leo_practice(athena_department)
  end

  def create_leo_practice(athena_department)
    if !athena_department
      @logger.error "Could not create leo_practice for nil athena_department"
      return
    end
    Practice.create!(parse_athena_department_json(athena_department))
  end

  def parse_athena_department_json(department)
    {
      athena_id: department["departmentid"],
      name: department["patientdepartmentname"],
      address_line_1: department["address"],
      city: department["city"],
      state: department["state"],
      zip: department["zip"],
      phone: department["phone"],
      email: nil,
      time_zone: "Eastern Time (US & Canada)" # deal with time zones later. assume eastern
    }
  end


  # PROVIDERS

  def update_or_create_leo_provider(leo_provider, athena_provider, practice)
    return create_leo_provider(athena_provider, practice) if !leo_provider
    update_leo_provider(leo_provider, athena_provider)
  end

  def update_leo_provider(leo_provider, athena_provider)
    leo_provider.update_attributes!(parse_athena_provider_json(athena_provider))
    leo_provider
  end

  def create_leo_provider(athena_provider, practice)
    if !athena_provider
      @logger.error "Could not create leo_provider for nil athena_provider"
      return
    end
    provider = ProviderSyncProfile.create!(parse_athena_provider_json(athena_provider).merge({practice: practice}))
    create_default_provider_schedule(provider)
    provider
  end

  def parse_athena_provider_json(athena_provider)
    practice = Practice.find_by(athena_id: athena_provider["departmentid"])
    {
      athena_id: get_athena_id(athena_provider),
      first_name: athena_provider["firstname"],
      last_name: athena_provider["lastname"],
      credentials: athena_provider["providertype"],
      practice: practice,
      athena_department_id: athena_provider["departmentid"]
    }
  end


  # HELPERS

  def get_athena_id(athena_provider)
    athena_provider["providerid"].try(:to_i)
  end

  def create_default_provider_schedule(provider)
    provider_schedule_attributes = {
      athena_provider_id: provider.athena_id,
      description: "Default Schedule",
      active: true,
      monday_start_time: "08:00",
      monday_end_time: "11:00",
      tuesday_start_time: "08:00",
      tuesday_end_time: "18:00",
      wednesday_start_time: "10:00",
      wednesday_end_time: "19:20",
      thursday_start_time: "08:00",
      thursday_end_time: "13:00",
      friday_start_time: "09:00",
      friday_end_time: "18:00",
      saturday_start_time: "00:00",
      saturday_end_time: "00:00",
      sunday_start_time: "00:00",
      sunday_end_time: "00:00"
    }
    if provider_schedule = ProviderSchedule.find_by(athena_provider_id: provider.athena_id)
      provider_schedule.update_attributes!(provider_schedule_attributes)
    else
      provider_schedule = ProviderSchedule.create!(provider_schedule_attributes)
    end
    provider_schedule
  end
end