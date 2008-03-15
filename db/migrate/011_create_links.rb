class CreateLinks < ActiveRecord::Migration
  def self.up
    create_table :links do |t|
      t.integer :from_page_id
      t.integer :to_page_id

      t.timestamps
    end
  end

  def self.down
    drop_table :links
  end
end
