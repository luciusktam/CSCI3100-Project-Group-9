class HomeController < ApplicationController
  def index
     @fresh_listings = Listing.order(created_at: :desc).limit(6)
  end
  
  def login
  end

  def community
  end

  def chat
  end

  def sell
  end

  def profile
  end
end