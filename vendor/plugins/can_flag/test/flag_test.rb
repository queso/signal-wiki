require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

class Article < ActiveRecord::Base
  can_be_flagged
  attr_accessor :called_back
  
  def after_flagged
    @called_back = true
  end
end

class FlagTest < Test::Unit::TestCase
  
  def test_calls_back_to_article
    article = Article.create :title => "My article", :body => "Five five five", :user_id => 1
    assert ! article.called_back
    flag = Flag.create! :flaggable => article
    assert article.called_back, "Article should call 'after_flagged' callback"
  end
  
  def test_sets_flaggable_user_id
    article = Article.create :title => "My article", :body => "Five five five", :user_id => 1
    flag = Flag.create :flaggable => article
    flag.save!
    assert_equal 1, flag.flaggable_user_id
  end
  
  def test_only_allows_valid_reasons
    Article.class_eval { can_be_flagged :reasons => [ :foolish ] }
    article = Article.create :title => "My article", :body => "Five five five", :user_id => 1
    flag = Flag.create :flaggable => article, :reason => "foolish"
    assert flag.save!
    flag.reason = "Monkeys"
    assert ! flag.save
  end
end