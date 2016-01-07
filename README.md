# Binarize [![Build Status](https://travis-ci.org/thanashyam/binarize.svg?branch=master)](https://travis-ci.org/thanashyam/binarize) 

Similar to ActiveRecord serialize, it saves multiple binary flags in a single column (integer or string)

This gem allows you to store multiple bit flags in a single column saving you from migrating and maintaining multiple columns in your DB every time, your application needs a new flag to be saved in DB.

# Compatibility

Tested with Ruby 2.1 and ActiveRecord 3.2, 4.1 and 4.2

# Example
```ruby
class Car < ActiveRecord::Base
    self.table_name = :cars
    include Binarize
    
    binarize :safety, flags: [:tpms, :abs, :ebd, :tcs]
  end
```
# How to use
```ruby
# Setting value for the flags
car = Car.new(name: "Model X", brand: "Tesla")

car.toggle_abs_safety
car.abs_safety = true #or false

# Reading the flag values
car.abs_safety? #Returns true or false
car.any_safety? #Returns where any of the column is set to true
car.all_safety? #Return whether all of the columns are set to true

car.in_safety? #Returns an array containing the flags set to true
car.not_in_safety? #Returns an array containing the flags set to false

#Other Methods
car.abs_safety_changed? #Returns whether a flag has an unsaved change.
```

You can specify upto 63 flags for an unsigned bigint column (as of MySQL 5.5)
If you are using a varchar(255) column, you store upto a whopping 847 flags.

Please make sure that you never even change the order of the flags.


