# Include hook code here
require 'can_flag'
ActiveRecord::Base.send(:include, Caboose::Can::Flag)
