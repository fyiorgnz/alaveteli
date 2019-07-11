class DeleteOldThingsWorker
  include Sidekiq::Worker

  def perform
    PostRedirect.delete_old_post_redirects
    TrackThingsSentEmail.delete_old_track_things_sent_email
  end
end
