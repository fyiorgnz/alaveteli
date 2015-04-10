class RemoveCharityNumber < ActiveRecord::Migration
  def self.up
    remove_column :public_bodies, :charity_number
  end

  def self.down
    fail 'No reverse migration'
  end
end
