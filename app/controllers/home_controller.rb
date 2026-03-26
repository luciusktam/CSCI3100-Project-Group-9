class HomeController < ApplicationController
  def index
    @latest_listings = Listing.order(created_at: :desc).limit(8)
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
