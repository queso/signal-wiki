class AddPrivateToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :private_page, :boolean
  end

  def self.down
    remove_column :pages, :private
  end
end
