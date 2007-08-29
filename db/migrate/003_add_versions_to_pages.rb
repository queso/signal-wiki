class AddVersionsToPages < ActiveRecord::Migration
  def self.up
    Page.create_versioned_table
  end

  def self.down
    Page.drop_versioned_table
  end
end
