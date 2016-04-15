module Syncable
  extend ActiveSupport::Concern

  included do
    belongs_to :sync_status, dependent: :destroy
  end

  def has_synced?
    athena_id > 0
  end
end
