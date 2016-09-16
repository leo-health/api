class AthenaPracticeSyncService < AthenaSyncService

  # TODO: To allow multiple Athena instances to sync with the same Leo instance, must scope athena_ids within a single practice, decide how to handle multiple departments within a practice
  # NOTE: sync_departments currently not used
  def sync_departments(limit: nil)
    departments = @connector.get_departments
    departments = departments[0...limit] if limit
    existing_practices = Practice.where(athena_id: departments.map {|dep| dep["departmentid"]})
    departments.map { |department|
      practice = existing_practices.find_by(athena_id: department["departmentid"])
      practice ||= create_leo_practice(department)
    }
  end

  def sync_providers(practice) # NOTE: Providers are not associated with a Department!
    athena_providers = @connector.get_providers.sort_by(&method(:get_athena_id))
    # For the sake of simple and quick testing, only sync the first 3 providers
    athena_providers = athena_providers[0...3]
    existing_providers = Provider.where(athena_id: athena_providers.map(&method(:get_athena_id))).order(:athena_id).to_enum
    existing_provider = nil
    athena_providers.map { |athena_provider|
      leo_provider = nil
      begin
        existing_provider ||= existing_providers.next
      rescue StopIteration
      end

      if existing_provider && existing_provider.athena_id == get_athena_id(athena_provider)
        leo_provider = existing_provider
        existing_provider = nil
      end
      leo_provider ||= create_leo_provider(athena_provider, practice)
    }
  end

  def sync_appointment_types(practice)
    athena_appointment_types = @connector.get_appointment_types
    athena_appointment_types.map { |athena_appointment_type|
      athena_id = athena_appointment_type["appointmenttypeid"].try(:to_i)

      # Assumes that user_facing_appointment_types and the mapping are seeded
      user_facing_appointment_type = AppointmentType.user_facing_appointment_type_for_athena_id(athena_id)

      # only updates the hidden ones - creates a hidden one for each athena_id regardless if a visible one is already seeded
      AppointmentType.update_or_create([:athena_id, :hidden], {
        athena_id: athena_id,
        duration: athena_appointment_type["duration"].try(:to_i),
        short_description: athena_appointment_type["name"],
        long_description: athena_appointment_type["name"],
        name: athena_appointment_type["name"],
        user_facing_appointment_type: user_facing_appointment_type,
        hidden: true
      })
    }
  end

  private

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

    attributes = parse_athena_provider_json(athena_provider).merge(practice: practice)
    provider = nil
    ActiveRecord::Base.transaction do
      provider = Provider.create(attributes.merge(athena_department_id: practice.athena_id))
      StaffProfile.create_with_provider!(provider)
      ProviderSchedule.create_default_with_provider!(provider)
    end
    provider
  end

  def parse_athena_provider_json(athena_provider)
    {
      athena_id: get_athena_id(athena_provider),
      first_name: athena_provider["firstname"],
      last_name: athena_provider["lastname"],
      credentials: [athena_provider["providertype"]]
    }
  end

  # Helpers

  def get_athena_id(athena_provider)
    athena_provider["providerid"].try(:to_i)
  end
end
