class AlertTracksWorker
  include Sidekiq::Worker

  def perform
    TrackMailer.alert_tracks
  end
end
