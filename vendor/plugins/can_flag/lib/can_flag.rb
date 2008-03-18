# CanFlag
module Caboose
  module Can 
    module Flag
      def self.included(base)
        base.extend ClassMethods  
        if defined?(::ActiveSupport::Callbacks)
          base.define_callbacks :after_flagged
        end
      end

      module ClassMethods
        # Call can_be_flagged from your content model, or from anything
        # you want to flag.
        def can_be_flagged(opts={})
          has_many :flags, :as => :flaggable, :dependent => :destroy
          validates_associated :flags, :message => 'failed to validate'
          include Caboose::Can::Flag::InstanceMethods
          extend  Caboose::Can::Flag::SingletonMethods
          cattr_accessor :reasons
          self.reasons = opts[:reasons] || [:inappropriate]
          (::Flag.flaggable_models ||= []) << self
        end
        
        # Call can_flag from your user model, or anything that can own a flagging.
        # That's a paddlin!
        # Limitation for now: you should only allow one model to own flags.
        # This is ridiculously easy to make polymorphic, but no ponies yet.
        def can_flag
          # has_many :flaggables, :foreign_key => "user_id"
          # User created these flags
          has_many :flags, :foreign_key => "user_id", :order => "id desc"
          
          # User was responsible for creating this filth
          has_many :flaggings, :foreign_key => "flaggable_user_id", :class_name => "Flag"
          include CanFlagInstanceMethods
          
          # Associate the flag back here
          # Flag.belongs_to :user
          # Flag.belongs_to :owner, :foreign_key => flaggable_user_id
          ::Flag.class_eval "belongs_to :#{name.underscore}, :foreign_key => :user_id; 
            belongs_to :owner, :foreign_key => :flaggable_user_id, :class_name => '#{name}'"
        end
      end
      
      # This module contains class methods
      module SingletonMethods
      #  # Helper method to lookup for flags for a given object.
      #  # This method is equivalent to obj.flags.
      #  def find_flags_for(obj)
      #    flaggable = ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s
      #   
      #    Flag.find(:all,
      #      :conditions => ["flaggable_id = ? and flaggable_type = ?", obj.id, flaggable],
      #      :order => "created_at DESC"
      #    )
      #  end
      #  
      #  # Helper class method to lookup flags for
      #  # the mixin flaggable type written by a given user.  
      #  # This method is NOT equivalent to Flag.find_flags_for_user
      #  def find_flags_by_user(user) 
      #    flaggable = ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s
      #    
      #    Flag.find(:all,
      #      :conditions => ["user_id = ? and flaggable_type = ?", user.id, flaggable],
      #      :order => "created_at DESC"
      #    )
      #  end
      end
      
      module CanFlagInstanceMethods
        def flagged?(content)
          logger.warn "Looking for flags with #{content.inspect} #{content.class.name}"
          ::Flag.find(:first,
            :conditions => { :flaggable_type => content.class.name, :flaggable_id => content[:id] })
        end
      end
      
      ## This module contains instance methods
      module InstanceMethods
        
        def flagged?
          flags.size > 0
        end
        
        # Flag content with a mass-updater; sets the flagging user.
        # article.update_attributes { 'flagged' => current_user.id }
        def flagged=(by_who)
          flags.build :user_id => by_who
        end
      #  
      #  # Check to see if the passed in user has flagged this object before.
      #  # Optionally you can test to see if this user has flagged this object
      #  # with a specific flag
      #  def user_has_flagged?(user, flag = nil)
      #    conditions = flag.nil? ? {} : {:flag => flag}
      #    conditions.merge!({:user_id => user.id})
      #    return flags.count(:conditions =>conditions) > 0
      #  end
      #  
      #  # Count the number of flags tha have this specific
      #  # flag set
      #  def count_flags_with_flag(flag)
      #    flags.count(:conditions => ["flag = ?", flag])
      #  end
      #  
      #  # Add a flag.  You can either pass in an
      #  # instance of a flag or pass in a hash of attributes to be used to 
      #  # instantiate a new flag object
      #  def add_flag(options)
      #    if options.kind_of?(Hash)
      #      flag = Flag.new(options)
      #    elsif options.kind_of?(Flag)
      #      flag = options
      #    else
      #      raise "Invalid options"
      #    end
      #    
      #    flags << flag
      #    
      #    # Call flagged to allow model to handle the act of being
      #    # flagged
      #    flagged(flag.flag, count_flags_with_flag(flag.flag))
      #  end
      #  
      #  # Meant to be overriden
      #  protected
      #  def flagged(flag, flag_count)
      #  end
      end
      
    end
  end
end
