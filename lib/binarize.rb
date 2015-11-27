module Binarize
  
  def self.included(base)
    base.extend(ClassMethods)
    base.include(InstanceMethods)
    base.class_attribute :binarize_config unless defined?(base.binarize_config)
  end
  
  TRUE_VALUES = [true, 1, "1", "t", "T", "true", "TRUE", :true]

  module ClassMethods
    def binarize(column, flags: [], as: :integer)
      self.binarize_config ||= {}
      return unless validate_binarize_config(column, flags, as)
      
      column = column.to_sym
      add_config(column, flags, as)
      define_methods(column)
    end
    
    private
    
    def validate_binarize_config(column, flags, as)
      
      unless self.column_names.include?(column.to_s)
        warn "Unable to find `#{column}` column. Please make sure the migrations have been ran."
        return false
      end
      
      if binarize_config.keys.include?(column)
        warn "#{column} has already been binarized."
        return false
      end
      
      unless flags.is_a?(Array) && flags.size > 1
        raise "Flag set for #{column} is not an array( with 2 or more items)."
        return false
      end
      true
      
    end
    
    def add_config(column, flags, as)
      self.binarize_config[column] = {
        :flags => flags,
        :as => as,
        :flag_mapping => prep_mapping(flags)
      }
    end
    
    def prep_mapping(flags)
      flags.size.times.to_a.inject({}) do |result, index|
        result.merge({ flags[index] => (1 << index) })
      end
    end
    
    def define_methods(column)
      define_column_methods(column)
      self.binarize_config[column][:flags].each do |flag|
        define_flag_methods(column, flag)
      end
    end
    
    def define_column_methods(column)
      
      self.class.send(:define_method, "#{column}_flags") do
        binarize_config[column][:flags] || []
      end
      
      define_method "#{column}_values" do
        (self.binarize_config[column][:flags].inject({}) do |result, flag|
          result.merge({ flag => flag_value(column, flag) })
        end)
      end
      
      define_method "all_#{column}?" do
        send("#{column}_values").values.all?
      end
      
      define_method "any_#{column}?" do
        send("#{column}_values").values.any?
      end
      
      define_method "in_#{column}" do
        self.binarize_config[column][:flags].select { |flag| self.send("#{flag}_#{column}?") }
      end
      
      define_method "not_in_#{column}" do
        self.binarize_config[column][:flags].reject { |flag| self.send("#{flag}_#{column}?") }
      end
        
    end
    
    def define_flag_methods(column, flag)
      
      define_method "#{flag}_#{column}?" do
        flag_value(column, flag)
      end
      
      define_method "mark_#{flag}_#{column}" do
        self[column] = self[column].to_i | flag_mapping(column, flag)
      end
      
      define_method "unmark_#{flag}_#{column}" do
        self[column] = self[column].to_i & ~flag_mapping(column, flag)
      end
      
      define_method "toggle_#{flag}_#{column}" do
        send("#{flag}_#{column}?") ? send("unmark_#{flag}_#{column}") : send("mark_#{flag}_#{column}")
      end
      
      define_method "#{flag}_#{column}=" do |value|
        Binarize::TRUE_VALUES.include?(value) ? send("mark_#{flag}_#{column}") : send("unmark_#{flag}_#{column}")
      end
      
      define_method "#{flag}_#{column}_changed?" do
        flag_map = flag_mapping(column, flag)
        # puts "self.changes.include?(column)"
        # puts self.changes.include?(column)
        # 
        # puts "(self[column].to_i & flag_map)"
        # puts (self[column].to_i & flag_map)
        # puts "(self.changes[column].first.to_i & flag_map)"
        # puts (self.changes[column].first.to_i & flag_map)
        self.changes.include?(column) && ((self[column].to_i & flag_map) != (self.changes[column].first.to_i & flag_map))
      end
      
    end
    
  end
  
  module InstanceMethods
    
    private
    def flag_value(column, flag)
      column = column.to_sym
      raise "Invalid Binary Column specified" unless self.class.binarize_config.keys.include?(column)
      raise "Flag not available in the Binary Column specified" unless self.class.binarize_config[column][:flags].include?(flag)
      
      flag_map = flag_mapping(column, flag)
      (self[column].to_i & flag_map) == flag_map
    end
    
    def flag_mapping(column, flag)
      self.class.binarize_config[column][:flag_mapping][flag]
    end
    
  end
end