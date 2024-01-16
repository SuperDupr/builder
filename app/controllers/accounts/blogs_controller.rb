class Accounts::BlogsController < Accounts::BaseController
  before_action :authenticate_user!
  before_action :set_account
  before_action :set_blog, only: [:show]

  def index
    @featured_blogs = Blog.where("public_access = ? OR id IN (?)", true, @account.shared_blogs.published.pluck(:id)).limit(2)
    @recent_blogs = Blog.where("public_access = ? OR id IN (?)", true, @account.shared_blogs.published.pluck(:id)).offset(2).limit(3)
    # @blogs = Blog.where("public_access = ? OR id IN (?)", true, @account.shared_blogs.published.pluck(:id)).limit(6)
    # @pagy, @blogs = pagy(@blogs, items: 6)
    # @pagy_1, @public_blogs = pagy(Blog.where(public_access: true), items: 6)
    # @pagy, @blogs = pagy(@account.shared_blogs.published, items: 6)
  end

  def all_blogs
    @blogs = Blog.where("public_access = ? OR id IN (?)", true, @account.shared_blogs.published.pluck(:id)).limit(6)
    @pagy, @blogs = pagy(@blogs, items: 9)
  end

  def show
  end

  private

  def set_blog
    @blog = @account.shared_blogs.published.find_by(id: params[:id]) ||
      Blog.find_by(id: params[:id], public_access: true)
  end

  def set_account
    @account = current_account
  end
end
