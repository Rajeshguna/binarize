require 'helper'
require 'binarize'
class TestBinarize < Minitest::Test
  
  
  FLAGS_COLUMNS = {
    :safety => [:tpms, :abs, :ebd, :tcs],
    :security => [:immobilizer, :speed_lock, :child_safety_lock],
    :comfort => [:aircon, :rear_ac_vent, :cruise_control, :driver_armrest],
    :instrumentation => [
                  :trip_meter, :dte, :fuel_warning, 
                  :shift_indicator, :hud, :tachometer, 
                  :music, :nav, :video, 
                  :android_auto, :car_play
                ]
  }
  
  FALSE_VALUES = [false, 0, :nope, "nothing", "random", 99]
  # Any value apart from the ones in the TRUE_VALUES is considered to be negative
  
  class Car < ActiveRecord::Base
    self.table_name = :cars
    include Binarize
    
    FLAGS_COLUMNS.each do |k,v|
      if FLAGS_COLUMNS.keys.first(2).include?(k)
        binarize k, flags: v
      else
        binarize k, flags: v, as: :string
      end
    end
  end
  
  
  describe "Binarize" do
    before do
      Car.destroy_all
    end
    
    
    it "respond_to and return list of flags present in a column" do
      
      FLAGS_COLUMNS.keys.each do |column|
        # #{column_name}_flags
        # Method to find the list of Flags present in that column.
        assert_respond_to(Car, :"#{column}_flags")
        
        assert_equal FLAGS_COLUMNS[column], Car.send(:"#{column}_flags")
      end
    end
    
    
    it "have the all the column based methods defined" do
      
      car = Car.new
      
      FLAGS_COLUMNS.each do |column, flags|
        
        # any_{column_name}?
        # Is any of the flags in this column set to true?
        assert_respond_to(car, :"any_#{column}?")
        
        # all_{column_name}?
        # Are all the flags in this column set to true?
        assert_respond_to(car, :"all_#{column}?")
        
        
        # {column_name}_present
        # List flags in this column set to true
        assert_respond_to(car, :"in_#{column}")
        
        # {column_name}_present
        # List flags in this column set to false
        assert_respond_to(car, :"not_in_#{column}")
        
        # {column_name}_values
        # Flags and their values in this column
        assert_respond_to(car, :"#{column}_values")
      end
      
    end
    
    it "have respond to all the flag based methods defined" do
      
      car = Car.new
      FLAGS_COLUMNS.each do |column, flags|
        flags.each do |flag|
          # Whether the flag is true or false
          assert_respond_to(car, :"#{flag}_#{column}?")
          
          # Set the flag to true
          assert_respond_to(car, :"mark_#{flag}_#{column}")
          
          # Set the flag to false
          assert_respond_to(car, :"unmark_#{flag}_#{column}")
          
          # Toggle the flag value
          assert_respond_to(car, :"toggle_#{flag}_#{column}")
          
          # Set the value for the flag
          assert_respond_to(car, :"#{flag}_#{column}=")
          
          # Check where the value for the flag has been changed
          assert_respond_to(car, :"#{flag}_#{column}_changed?")
        end
      end
      
    end

    it "return false for any_{column} and all_{column} for all the binarize columns for a new object" do
      
      car = Car.new
      FLAGS_COLUMNS.each do |column, flags|
        assert_equal false, car.send(:"any_#{column}?")
        assert_equal false, car.send(:"all_#{column}?")
      end
    end

    it "set the values for a flag properly using mark and unmark methods" do
      car = Car.new(name: "Model X", brand: "Tesla")
      
      chosen_flags = {}
      FLAGS_COLUMNS.each do |column, flags|
        chosen_flags[column] = flags.sample(flags.size/2)
        chosen_flags[column].each do |flag|
          car.send(:"mark_#{flag}_#{column}")
          assert_equal true, car.send(:"#{flag}_#{column}?")
        end
        
        (flags - chosen_flags[column]).each do |flag|
          assert_equal false, car.send(:"#{flag}_#{column}?")
        end
        
        assert_equal true, car.send(:"any_#{column}?")
        assert_equal false, car.send(:"all_#{column}?")
        
        
        assert_equal_arrays chosen_flags[column], car.send(:"in_#{column}")
        assert_equal_arrays (flags - chosen_flags[column]), car.send(:"not_in_#{column}")
        
      end
      
      # Checking their values after saving the object
      car.save
      car.reload
      FLAGS_COLUMNS.each do |column, flags|
        chosen_flags[column].each do |flag|
          assert_equal true, car.send(:"#{flag}_#{column}?")
        end
        
        (flags - chosen_flags[column]).each do |flag|
          assert_equal car.send(:"#{flag}_#{column}?"), false
        end
        
        assert_equal true, car.send(:"any_#{column}?")
        assert_equal false, car.send(:"all_#{column}?")
        
        assert_equal_arrays chosen_flags[column], car.send(:"in_#{column}")
        assert_equal_arrays (flags - chosen_flags[column]), car.send(:"not_in_#{column}")
        
      end
      
      # Now unmarking a few of the ones that were marked previously
      removed_flags = {}
      FLAGS_COLUMNS.each do |column, flags|
        removed_flags[column] = chosen_flags[column].sample(chosen_flags[column].size/2)
        removed_flags[column].each do |flag|
          car.send(:"unmark_#{flag}_#{column}")
          assert_equal false, car.send(:"#{flag}_#{column}?")
          assert_includes car.send(:"not_in_#{column}"), flag
        end
        assert_equal_arrays (flags - (chosen_flags[column] - removed_flags[column])), car.send(:"not_in_#{column}")
      end
      
      # Checking the unmarking assertions after saving
      car.save
      car.reload
      FLAGS_COLUMNS.each do |column, flags|
        removed_flags[column].each do |flag|
          assert_equal false, car.send(:"#{flag}_#{column}?")
          assert_includes car.send(:"not_in_#{column}"), flag
        end
        assert_equal_arrays (flags - (chosen_flags[column] - removed_flags[column])), car.send(:"not_in_#{column}")
      end
      
      # Toggling those removed columns now
      FLAGS_COLUMNS.each do |column, flags|
        removed_flags[column].each do |flag|
          car.send(:"toggle_#{flag}_#{column}")
          assert_equal true, car.send(:"#{flag}_#{column}?")
          assert_includes car.send(:"in_#{column}"), flag
        end
        assert_equal_arrays chosen_flags[column], car.send(:"in_#{column}")
      end
      
      # Checking the Toggling stuff after save
      
      car.save
      car.reload
      FLAGS_COLUMNS.each do |column, flags|
        removed_flags[column].each do |flag|
          assert_equal true, car.send(:"#{flag}_#{column}?")
          assert_includes car.send(:"in_#{column}"), flag
        end
        assert_equal_arrays chosen_flags[column], car.send(:"in_#{column}")
      end
    end
    
    it "work when all the values are 0 or ''" do
      car = Car.new(name: "Model T", brand: "Ford")
      car.save
      
      car.reload
      FLAGS_COLUMNS.each do |column, flags|
        assert_equal [], car.send(:"in_#{column}")
        assert_equal false, car.send(:"any_#{column}?")
        assert_equal false, car.send(:"all_#{column}?")
        
        flags.each do |flag|
          car.send(:"mark_#{flag}_#{column}")
        end
      
        assert_equal_arrays flags, car.send(:"in_#{column}")
        assert_equal true, car.send(:"any_#{column}?")
        assert_equal true, car.send(:"all_#{column}?")
      end
      
      # Checking their values after saving the object
      car.save
      car.reload
      FLAGS_COLUMNS.each do |column, flags|
        assert_equal_arrays flags, car.send(:"in_#{column}")
        assert_equal true, car.send(:"any_#{column}?")
        assert_equal true, car.send(:"all_#{column}?")
      end
    end
    
    it "work with value assignment" do
      car = Car.new(name: "Creta", brand: "Hyundai")
      car.save
      
      flag_values = {}
      FLAGS_COLUMNS.each do |column, flags|
        flag_values[column] = {:positive => [], :negative => []}
        flags.each do |flag|
          flag_values[column][rand(10) < 5 ? :positive : :negative] << flag
        end
        
        flag_values[column][:positive].each do |flag|
          car.send(:"#{flag}_#{column}=", true)
          assert_equal true, car.send(:"#{flag}_#{column}?")
        end
        
        flag_values[column][:negative].each do |flag|
          car.send(:"#{flag}_#{column}=", false)
          assert_equal false, car.send(:"#{flag}_#{column}?")
        end
        
        assert_equal_arrays flag_values[column][:positive], car.send(:"in_#{column}")
        assert_equal_arrays flag_values[column][:negative], car.send(:"not_in_#{column}")
        
      end
      
      car.save
      car.reload
      
      FLAGS_COLUMNS.each do |column, flags|
        flag_values[column][:positive].each do |flag|
          assert_equal true, car.send(:"#{flag}_#{column}?")
        end
        
        flag_values[column][:negative].each do |flag|
          assert_equal false, car.send(:"#{flag}_#{column}?")
        end
        # ****
        assert_equal_arrays flag_values[column][:positive], car.send(:"in_#{column}")
        assert_equal_arrays flag_values[column][:negative], car.send(:"not_in_#{column}")
      end
    end
    
    it "work while assigning non boolean values for the flags" do
      car = Car.new(name: "Prius", brand: "Toyota")
      car.save
      car.reload
      
      flag_values = {}
      FLAGS_COLUMNS.each do |column, flags|
        flag_values[column] = {:positive => [], :negative => []}
        flags.each do |flag|
          flag_values[column][rand(10) < 5 ? :positive : :negative] << flag
        end
        
        flag_values[column][:positive].each do |flag|
          car.send(:"#{flag}_#{column}=", Binarize::TRUE_VALUES.sample)
          assert_equal true, car.send(:"#{flag}_#{column}?")
        end
        
        flag_values[column][:negative].each do |flag|
          car.send(:"#{flag}_#{column}=", FALSE_VALUES.sample)
          assert_equal false, car.send(:"#{flag}_#{column}?")
        end
        
        assert_equal_arrays flag_values[column][:positive], car.send(:"in_#{column}")
        assert_equal_arrays flag_values[column][:negative], car.send(:"not_in_#{column}")
        
      end
    end
    
    it "return true for _changed method when the values have been touched" do
      car = Car.new(name: "Civic", brand: "Honda")
      car.save
      car.reload
      
      flag_values = {}
      FLAGS_COLUMNS.each do |column, flags|
        flag_values[column] = {:positive => [], :negative => []}
        flags.each do |flag|
          assert_equal false, car.send(:"#{flag}_#{column}_changed?")
          flag_values[column][rand(10) < 5 ? :positive : :negative] << flag
        end
        
        flag_values[column][:positive].each do |flag|
          car.send(:"mark_#{flag}_#{column}")
          assert_equal true, car.send(:"#{flag}_#{column}_changed?")
        end
        
        flag_values[column][:negative].each do |flag|
          car.send(:"unmark_#{flag}_#{column}")
          assert_equal false, car.send(:"#{flag}_#{column}_changed?")
        end
      end
      
      car.save
      car.reload
      
      FLAGS_COLUMNS.each do |column, flags|
        flags.each do |flag|
          assert_equal false, car.send(:"#{flag}_#{column}_changed?")
          car.send(:"toggle_#{flag}_#{column}")
          assert_equal true, car.send(:"#{flag}_#{column}_changed?")
        end
        
      end
      
    end
  end
end
