class AlertTracksWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { minutely(10) }

  def perform
    TrackMailer.alert_tracks
  end
end
