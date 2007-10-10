ActiveRecord::Schema.define(:version => 1) do

  create_table :students do |t|
    t.column :name, :string
    t.column :level, :string
    t.column :age, :integer
    t.column :active, :boolean
    t.column :gpa, :decimal
    t.column :school_id, :integer
  end
  
  create_table :schools do |t|
    t.column :name, :string
    t.column :ivy_league, :boolean
    t.column :founded, :date
    t.column :bool_one, :boolean
    t.column :bool_two, :boolean
  end
end