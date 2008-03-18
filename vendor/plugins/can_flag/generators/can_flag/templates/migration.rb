class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    create_table "flags", :force => true do |t|
      t.integer :user_id
      t.integer :flaggable_id
      t.string  :flaggable_type
      t.integer :flaggable_user_id
      t.string  :reason
      t.timestamps
    end
    # todo: add index on reason
    # todo: add index on user_id
    # todo: add index on flaggable_user_id
  end

  def self.down
    drop_table "flags"
  end
end
