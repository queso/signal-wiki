class PageSiteFk < ActiveRecord::Migration
  def self.up
    add_column :pages, :site_id, :integer
    add_column :page_versions, :site_id, :integer
    Page.update_all 'site_id=1'
  end

  def self.down
    remove_column :pages, :site_id
    remove_column :page_versions, :site_id
  end
end
