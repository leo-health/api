# == Schema Information
#
# Table name: sync_tasks
#
#  id          :integer          not null, primary key
#  sync_id     :integer          default(0), not null
#  sync_source :integer          default(0), not null
#  sync_type   :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class SyncTask < ActiveRecord::Base
end
