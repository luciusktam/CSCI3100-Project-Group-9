class HomeController < ApplicationController
  def index
    @latest_listings = Listing.order(created_at: :desc).limit(8)
  end
end
