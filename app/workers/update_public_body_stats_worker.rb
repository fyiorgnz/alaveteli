class UpdatePublicBodyStatsWorker
  include Sidekiq::Worker

  def perform
    Rake.application['stats:update_public_bodies_stats'].invoke
  end
end
