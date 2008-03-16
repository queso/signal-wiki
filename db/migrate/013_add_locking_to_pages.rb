class AddLockingToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :locked_at, :datetime 
  end

  def self.down
    remove_column :pages, :locked_at
  end
end
