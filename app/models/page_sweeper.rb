class PageSweeper < ActionController::Caching::Sweeper
  observe Page

  def after_save(record)
    expire_record(record)
  end

  def expire_record(record)
    page_id = record.permalink
    logger.info "Record to expire is: " + page_id.to_s
    expire_page(hash_for_page_path(:id => page_id))
  end

end
