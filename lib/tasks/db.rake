# -*- encoding : utf-8 -*-

namespace :db do
  desc 'Waits until DB exists and is ready'
  task :wait_for_migration => :environment do
    # Check for pending migrations
    loop do
      begin
        ActiveRecord::Migration.check_pending!
      rescue ActiveRecord::PendingMigrationError
        print "Waiting for migrations to complete...\n"
        sleep(2.minutes)
      else
        break
      end
    end
  end

  desc 'Trigger Holding Pen Creation'
  task :holding_pen => :environment do
    ir = InfoRequest.holding_pen_request
  end
end

