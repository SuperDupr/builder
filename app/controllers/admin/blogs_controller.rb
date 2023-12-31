module Admin
  class BlogsController < Admin::ApplicationController
    before_action :set_blog, only: [:show, :edit, :update, :destroy, :share, :publish]

    def index
      @pagy, @blogs = pagy(Blog.includes(tags: [:taggings]).order(updated_at: :desc))
    end

    def new
      @blog = Blog.new
      get_selectable_accounts_and_tags
    end

    def create
      @blog = Blog.new(blog_params)
      mark_blog_as_published

      if @blog.save
        associate_accounts
        flash[:notice] = "Blog was created successfully!"
      else
        flash[:alert] = "Unable to create blog. Errors: #{@blog.errors.full_messages.join(", ")}"
      end

      redirect_to(admin_blogs_path)
    end

    def edit
      get_selectable_accounts_and_tags
    end

    def update
      mark_blog_as_published

      if @blog.update(blog_params)
        associate_accounts
        flash[:notice] = "Blog was updated successfully!"
      else
        flash[:alert] = "Unable to update blog. Errors: #{@blog.errors.full_messages.join(", ")}"
      end

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

    def associate_accounts
      supplied_account_ids = params[:account_ids].split(",").compact_blank.map(&:strip)
      shared_accounts = @blog.accounts_shared_with
      shared_account_ids = shared_accounts.pluck(:id)

      create_blog_shares(supplied_account_ids, shared_account_ids)
      remove_blog_shares(supplied_account_ids, shared_account_ids)
    end

    def publish
      @blog.update(published: true)

      respond_to do |format|
        format.json { render json: {published: @blog.published} }
      end
    end

    private

    def create_blog_shares(supplied_account_ids, shared_account_ids)
      blog_shares_to_be_added = []

      supplied_account_ids.each do |id|
        unless shared_account_ids.include?(id.to_i)
          blog_shares_to_be_added << {
            blog_id: @blog.id,
            account_id: id
          }
        end
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

    def get_selectable_accounts_and_tags
      @selectable_accounts = Account.active.where.not(owner_id: current_user.id)
      @joined_tag_list = @blog.tag_list&.join(", ")
      @joined_shared_account_ids = @blog.accounts_shared_with.pluck(:id).join(", ")
    end

    def mark_blog_as_published
      return unless blog_params[:public_access] == "1"
      @blog.published = true
    end

    def set_blog
      @blog = Blog.find(params[:id])
    end

    def blog_params
      params.require(:blog).permit(:title, :body, :published, :public_access, :tag_list)
    end
  end
end
