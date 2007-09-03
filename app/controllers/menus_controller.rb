class MenusController < ApplicationController

  def navbar
    respond_to do |format|
      format.js
    end
  end
end
