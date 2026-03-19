class ListingsController < ApplicationController
  before_action :authenticate_user!, only: [ :new, :create, :edit, :update, :destroy ]
  before_action :set_listing, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_user!, only: [ :edit, :update, :destroy ]
  def index
    @listings = Listing.all.order(created_at: :desc)
  end

  def new
    @listing = Listing.new
  end

  def create
    @listing = Listing.new(listing_params)
    @listing.user = current_user



    if @listing.save
      flash[:notice] = "Your item is listed！"
      redirect_to @listing
    else

      flash.now[:alert] = @listing.errors.full_messages.join(", ")
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end
  def edit
  end
  def update
    if @listing.update(listing_params)
      flash[:notice] = "Listing updated successfully！"
      redirect_to @listing
    else
      flash.now[:alert] = @listing.errors.full_messages.join(", ")
      render :edit, status: :unprocessable_entity
    end
  end
  def destroy
    @listing.destroy
    flash[:notice] = "Listing deleted successfully！"
    redirect_to listings_path
  end

  private

  def set_listing
    @listing = Listing.find(params[:id])
  end

  def authorize_user!
    unless @listing.user == current_user
      flash[:alert] = "You are not authorized to perform this action"
      redirect_to @listing
    end
  end

  def listing_params
    params.require(:listing).permit(
      :title, :price, :category, :condition, :location, :description,
      photos: [])
  end
end
