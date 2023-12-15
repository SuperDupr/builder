class Accounts::BlogsController < Accounts::BaseController
  before_action :authenticate_user!
  before_action :set_account
  before_action :set_blog, only: [:show]

  def index
    @pagy, @blogs = pagy(@account.shared_blogs, items: 6)
  end

  def show
  end

  private

  def set_blog
    @blog = @account.blogs.find(params[:id])
  end

  def set_account
    @account = current_account
  end
end
