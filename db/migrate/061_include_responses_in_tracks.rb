# -*- encoding : utf-8 -*-
class IncludeResponsesInTracks <  ActiveRecord::Migration[4.2] # 2.0
  def self.up
    TrackThing.update_all "track_query = replace(track_query, 'variety:sent ', '') where track_type in ('public_body_updates', 'user_updates')"
  end

  def self.down
    # TODO: forget it
  end
end
