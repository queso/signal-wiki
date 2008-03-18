require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

class Article < ActiveRecord::Base
end
class Content < ActiveRecord::Base
  set_table_name 'articles' # cheater
end

class CanBeFlaggedOptionsTest < Test::Unit::TestCase
  def setup
    Article.class_eval do
      can_be_flagged :reasons => [:porn, :troll]
    end
  end

  def test_sets_options_as_class_var
    assert_equal [:porn, :troll], Article.reasons
  end

  def test_does_not_leak_reasons_betwixt_classes
    Content.class_eval do
      can_be_flagged :reasons => [:spam]
    end
    assert_equal [:porn, :troll], Article.reasons
    assert_equal [:spam], Content.reasons
  end
end