class UpdatePublicBodyStatsWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { daily }

  def perform
    Rake.application['stats:update_public_bodies_stats'].invoke
  end
end
