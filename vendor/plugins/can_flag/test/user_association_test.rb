require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

class User<ActiveRecord::Base; end

class UserAssociationTest < Test::Unit::TestCase
  def test_creates_user_association_in_flag
    assert_nil Flag.reflect_on_association(:user)
    User.class_eval do
      can_flag
    end
    assert_not_nil Flag.reflect_on_association(:user)
  end
end

class User2<ActiveRecord::Base; set_table_name :users; end

class UserFlagAssociationTest < Test::Unit::TestCase
  
  def test_creates_flaggable_associations_in_user
    assert_nil User2.reflect_on_association(:flaggable)
    User2.class_eval do 
      can_flag
    end
    assert_not_nil User2.reflect_on_association(:flaggings)
    assert_equal :has_many, User2.reflect_on_association(:flaggings).macro
    assert_nothing_raised { User2.new.flaggings }
    assert_not_nil User2.reflect_on_association(:flags)
    assert_equal :has_many, User2.reflect_on_association(:flags).macro
    assert_nothing_raised { User2.new.flags }
  end
  
end