module PagesHelper
  
  def wikified_body(body)
    r = RedCloth.new(body)
    r.gsub!(/\[\[(.*)\]\]/) {wiki_link($1)}
    r.to_html
  end
  
  def wiki_link(wiki_words)
    permalink = wiki_words.downcase.gsub(' ', '-')
    link_to wiki_words, wiki_page_url(permalink), ({:class => "new_wiki_link"} if Page.exists?(permalink))
  end
  
end
