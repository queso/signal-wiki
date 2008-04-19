module PagesHelper
  
  def wikified_body(body)
    r = RedCloth.new(body)
    r.gsub!(/\[\[(.*?)(\|(.*?))?\]\]/) { wiki_link($1, $3) }
    sanitize r.to_html
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
    page = Page.find(id)
    page ? (version == page.version) : false
  end
  
  def body_input(f)
    text_input(f, 'body')
  end
  
  def text_input(f, attr)
    if site.disable_teh
      f.text_area attr.to_sym
    else
      textile_editor 'page', attr
    end
  end
  
end
