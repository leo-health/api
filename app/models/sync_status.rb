class SyncStatus < ActiveRecord::Base
  belongs_to :owner, polymorphic: true
  def table_name
    'sync_statuses'
  end
end
