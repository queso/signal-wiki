module PagesHelper
  
  def wikified_body(body)
    r = RedCloth.new(body)
    r.gsub!(/\[\[(.*)(\|(.*))?\]\]/) {wiki_link(*$1.split("|")[0..1])}
    r.to_html
  end
  
  def wiki_link(wiki_words, link_text = nil)
    permalink = wiki_words.downcase.gsub(' ', '-')
    if Page.exists?(:permalink => permalink)
      link_to((link_text || wiki_words), wiki_page_url(permalink))
    else
      link_to((link_text || wiki_words), wiki_page_url(permalink), :class => "new_wiki_link")
    end
  end
  
  def current_revision(id, version)
    version == Page.find(id).version
  end
  
  def body_input(f)
    if site.disable_teh
      f.text_area :body
    else
      textile_editor 'page', 'body'
    end
  end
  
end
