Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.max_run_time = 5.minutes
Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', 'dj.log'))
Delayed::Worker.default_queue_name = 'default'
Delayed::Worker.sleep_delay = 30
Delayed::Worker.max_attempts = 20
# SOURCE: http://stackoverflow.com/questions/7326301/how-do-i-find-a-specific-delayed-job-not-by-id
class Delayed::Job < ActiveRecord::Base
  belongs_to :owner, :polymorphic => true
  def self.queues
    all.pluck(:queue).uniq
  end
end
