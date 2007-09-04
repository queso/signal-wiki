class PageSweeper < ActionController::Caching::Sweeper
  observe Page

  def after_save(record)
    expire_record(record)
  end

  def expire_record(record)
    page_id = record.permalink
    logger.info "Record to expire is: " + page_id.to_s
    expire_page("/#{page_id}")
    expire_parent_links(page_id)
  end

  def expire_parent_links(permalink)
    wiki_word = permalink.split("-").join(" ")
    pages = Page.find_all_by_wiki_word(wiki_word)
    pages.each do |p| 
      expire_page("/#{p.permalink}")
      logger.info "Parent record to expire is: " + p.permalink.to_s
    end
  end

end
