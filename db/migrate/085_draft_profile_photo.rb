class DraftProfilePhoto < ActiveRecord::Migration
  def self.up
    add_column :profile_photos, :draft, :boolean, default: false, null: false
  end

  def self.down
    fail 'No reverse migration'
  end
end
