require 'rails_helper'

describe 'Whenever Schedule' do
  let(:schedule){Whenever::Test::Schedule.new(file: 'config/schedule.rb')}

  before do
    load 'Rakefile'
  end

  it 'makes sure `runner` statements exist' do
    expect(schedule.jobs[:rake].count).to eq(5)
  end

  it 'makes sure `rake` statements exist' do
    assert Rake::Task.task_defined?('notification:complete_user_two_day_prior_appointment')
    assert Rake::Task.task_defined?('notification:patient_birthday')
    assert Rake::Task.task_defined?('notification:escalated_conversation_email_digest')
    assert Rake::Task.task_defined?('notification:account_confirmation_reminder')
  end
end
