$:.unshift(File.dirname(__FILE__) + '/../lib')

ENV['RAILS_ENV'] = 'test'
ENV['RAILS_ROOT'] ||= '~/dev/oss/altered_beast/' #File.dirname(__FILE__) + '/../../../..'

require 'test/unit'
require File.expand_path(File.join(ENV['RAILS_ROOT'], 'config/environment.rb'))
require 'active_record/fixtures'
require 'action_controller/test_process'

config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")

# Cargo culted from attachment_fu!
db_adapter = ENV['DB']

# no db passed, try one of these fine config-free DBs before bombing.
db_adapter ||= 
  begin
    require 'rubygems'
    require 'sqlite'
    'sqlite'
  rescue MissingSourceFile
    begin
      require 'sqlite3'
      'sqlite3'
    rescue MissingSourceFile
    end
  end

if db_adapter.nil?
  raise "No DB Adapter selected.  Pass the DB= option to pick one, or install Sqlite or Sqlite3."
end

ActiveRecord::Base.establish_connection(config[db_adapter])

load(File.dirname(__FILE__) + "/schema.rb")

# Test::Unit::TestCase.fixture_path = File.dirname(__FILE__) + "/fixtures"
# $LOAD_PATH.unshift(Test::Unit::TestCase.fixture_path)
