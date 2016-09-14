namespace :backfill do
  desc 'ensure unique sessions by device_token'
  task destroy_stale_sessions: :environment do

    Session.where(device_type: "Simulator").destroy_all

    nil_sessions = Session.where(platform: :ios, device_token: nil)
    if nil_sessions.count > 0
      puts "#{nil_sessions.count} Sessions with nil device token exist"
    else
      Session.where(platform: :ios)
      .where.not(device_type: "Simulator")
      .order(:created_at)
      .reduce({}) { |acc, session| # Group sessions by device_token
        group = acc[session.device_token] || []
        group.append(session)
        acc[session.device_token] = group
        acc
      }.each { |device_token, sessions|
        sessions[0...-1].each(&:destroy) # destroy all except the greatest created_at
      }
    end
  end
end
