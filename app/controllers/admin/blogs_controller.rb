module Admin
  class BlogsController < Admin::ApplicationController
    before_action :set_blog, only: [:show, :edit, :update, :destroy, :share]

    def index
      @pagy, @blogs = pagy(Blog.includes(tags: [:taggings]))
    end

    def new
      @blog = Blog.new
    end

    def create
      @blog = Blog.new(blog_params)

      @blog.save ?
        flash[:notice] = "Blog was created successfully!" :
        flash[:alert] = "Unable to create blog. Errors: #{@blog.errors.full_messages.join(", ")}"

      redirect_to(admin_blogs_path)
    end

    def edit
    end

    def update
      @blog.update(blog_params) ?
        flash[:notice] = "Blog was updated successfully!" :
        flash[:alert] = "Unable to update blog. Errors: #{@blog.errors.full_messages.join(", ")}"

      redirect_to(admin_blogs_path)
    end

    def show
    end

    def destroy
      @blog.destroy ?
        flash[:notice] = "Blog was deleted successfully!" :
        flash[:alert] = "Unable to delete blog!"
      redirect_to(admin_blogs_path)
    end

    def share
      supplied_account_ids = params[:account_ids].split(",").compact_blank.map(&:strip)
      shared_accounts = @blog.accounts_shared_with
      shared_account_ids = shared_accounts.pluck(:id)

      create_blog_shares(supplied_account_ids, shared_account_ids)
      remove_blog_shares(supplied_account_ids, shared_account_ids)

      respond_to do |format|
        format.json { render json: { accounts: shared_accounts.reload } }
      end
    end

    private

    def create_blog_shares(supplied_account_ids, shared_account_ids)
      blog_shares_to_be_added = []

      supplied_account_ids.each do |id|
        blog_shares_to_be_added << { 
          blog_id: @blog.id, 
          account_id: id 
        } unless shared_account_ids.include?(id.to_i)
      end

      BlogShare.insert_all(blog_shares_to_be_added) unless blog_shares_to_be_added.empty?
    end

    def remove_blog_shares(supplied_account_ids, shared_account_ids)
      removable_blog_share_account_ids = []

      shared_account_ids.each do |id|
        unless supplied_account_ids.include?(id.to_s)
          removable_blog_share_account_ids << id 
        end
      end

      BlogShare.where(account_id: removable_blog_share_account_ids).delete_all unless removable_blog_share_account_ids.empty?
    end

    def set_blog
      @blog = Blog.find(params[:id])
    end

    def blog_params
      params.require(:blog).permit(:title, :body, :published, :tag_list)
    end
  end
end
