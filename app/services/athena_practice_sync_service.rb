class AthenaPracticeSyncService < AthenaSyncService
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

  def get_athena_id(athena_provider)
    athena_provider["providerid"].try(:to_i)
  end

  def parse_athena_provider_json(athena_provider)
    {
      athena_id: get_athena_id(athena_provider),
      first_name: athena_provider["firstname"],
      last_name: athena_provider["lastname"],
      credentials: athena_provider["providertype"]
    }
  end

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
