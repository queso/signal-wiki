class Site < ActiveRecord::Base
end

class CreateSites < ActiveRecord::Migration
  def self.up
    create_table :sites do |t|
      t.string :title
      t.string :akismet_key
      t.string :akismet_url
      t.boolean :require_approval
      t.boolean :require_login_to_post
      t.boolean :disable_teh

      t.timestamps 
    end
    Site.create :title => 'Signal', :require_login_to_post => false
  end

  def self.down
    drop_table :sites
  end
end
