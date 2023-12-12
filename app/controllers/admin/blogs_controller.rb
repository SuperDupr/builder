module Admin
  class BlogsController < Admin::ApplicationController
    before_action :set_blog, only: [:show, :edit, :update, :destroy]

    def index
      @pagy, @blogs = pagy(Blog.all.includes(:rich_text_body))    
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

    private

    def set_blog
      @blog = Blog.find(params[:id])      
    end

    def blog_params
      params.require(:blog).permit(:title, :body, :published, tags: [])      
    end
  end
end
