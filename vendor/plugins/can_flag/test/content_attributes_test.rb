require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

class Article < ActiveRecord::Base
  can_be_flagged
end

class ContentAttributesTest < Test::Unit::TestCase
  def test_article_cab_has_attributes_like_states
    a = Article.new
    assert a.respond_to?(:flagged?), "Should have the 'flagged?' method defined"
    assert a.respond_to?(:flagged=), "Should have the 'flagged=' writer defined"
  end
  
  def test_article_can_has_writer
    a = Article.new
    assert ! a.flagged?, "Article should not be flagged by default"
    a.attributes = { 'flagged' => true }
    assert a.flagged? 
  end

end