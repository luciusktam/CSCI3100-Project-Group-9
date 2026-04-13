class CommunityPostsController < ApplicationController
  before_action :set_community_post, only: [ :show, :edit, :update, :destroy ]
  before_action :require_login_for_posting, only: [ :new, :create, :edit, :update, :destroy ]
  before_action :require_owner, only: [ :edit, :update, :destroy ]

  def index
    @query = params[:query].to_s.strip

    @community_posts = CommunityPost.includes(:user, :comments)

    if @query.present?
      @community_posts = @community_posts.fuzzy_search(@query)
    end

    if params[:user_id].present?
      @target_user = User.find_by(id: params[:user_id])
      @community_posts = @community_posts.where(user_id: params[:user_id])
    end

    @community_posts = @community_posts.reorder(created_at: :desc)
                                       .page(params[:page])
                                       .per(5)

  Rails.logger.debug "PARAMS: #{params.to_unsafe_h}"
  Rails.logger.debug "POSTS: #{@community_posts.map(&:title)}"
  end


  def show
    @comments = @community_post.comments.order(created_at: :asc, id: :asc)
    @comment = Comment.new
  end


  def new
    @community_post = CommunityPost.new
  end

  def create
    @community_post = current_user.community_posts.build(community_post_params)

    if @community_post.save
      redirect_to community_path, notice: "Post created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end


  def edit
  end

  def update
    if @community_post.update(community_post_params)
      redirect_to community_post_path(@community_post), notice: "Post updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @community_post.destroy
    redirect_to community_path, notice: "Post deleted successfully."
  end


  private

  def set_community_post
    @community_post = CommunityPost.find(params[:id])
  end

  def community_post_params
    params.require(:community_post).permit(:title, :content)
  end


  def require_login_for_posting
    unless user_signed_in?
      redirect_to login_path, alert: "Please log in before creating a community post"
    end
  end

  def require_owner
    redirect_to community_path, alert: "You are not allowed to do that." unless @community_post.user == current_user
  end
end
