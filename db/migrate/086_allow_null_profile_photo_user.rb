class AllowNullProfilePhotoUser < ActiveRecord::Migration
  def self.up
    change_column :profile_photos, :user_id, :integer, null: true
  end

  def self.down
    fail 'No reverse migration'
  end
end
