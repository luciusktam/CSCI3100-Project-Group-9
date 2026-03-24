class ListingsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_listing, only: [:show, :edit, :update, :destroy]
  before_action :authorize_user!, only: [:edit, :update, :destroy]


  def index
    @listings = Listing.all

    if params[:q].present?
      q = "%#{params[:q]}%"
      @listings = @listings.where(
        "title ILIKE :q OR description ILIKE :q OR location ILIKE :q",
        q: q
      )
    end

    @listings = @listings.order(created_at: :desc).page(params[:page]).per(20)
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
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    @listing.assign_attributes(listing_params.except(:photos))
    current_photo_count = @listing.photos.count

    photos_to_remove = params[:remove_photos].present? ? params[:remove_photos].split(",").map(&:strip) : []
    new_photos = listing_params[:photos].present? ? listing_params[:photos].reject(&:blank?) : []

    final_photo_count = current_photo_count - photos_to_remove.size + new_photos.size

    if final_photo_count == 0
      @listing.errors.add(:photos, "required")
      render :edit, status: :unprocessable_entity
      return
    end

    handle_remove_photos
    handle_new_photos

    if @listing.save
      if @listing.photos.attached?
        flash[:notice] = "Listing updated successfully！"
        redirect_to @listing
      else
        @listing.errors.add(:photos, "can't be blank")
        render :edit, status: :unprocessable_entity
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @listing.destroy
    flash[:notice] = "Listing deleted successfully！"
    redirect_to listings_path
  end

  private

  def handle_remove_photos
    return unless params[:remove_photos].present?

    photo_ids = params[:remove_photos].split(",").map(&:strip)

    photo_ids.each do |photo_id|
      photo = @listing.photos.find_by(id: photo_id)
      photo&.purge
    end
  end

  def handle_new_photos
    return unless listing_params[:photos].present?

    new_photos = listing_params[:photos].reject(&:blank?)
    @listing.photos.attach(new_photos) if new_photos.any?
  end

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
      photos: []
    )
  end
end
