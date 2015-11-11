ActiveRecord::Schema.define(:version => 0) do
  
  # A table giving space for Integer and String columns to store flags
  create_table :cars, :force => true do |t|
    t.string :name, :null => false
    t.string :brand, :null => false
    t.integer :safety, :default => 0
    t.integer :security, :default => 0
    t.string :comfort, :default => ''
    t.string :instrumentation, :default => ''
  end
  
  # A table without any column for flags.
  create_table :users, :force => true do |t|
    t.string :name, :null => false
    t.string :age, :default => 18
  end
  
  

end