class Admin::StoryBuildersController < Admin::ApplicationController
  before_action :set_story_builder, only: [:show, :edit, :update, :destroy]

  def index
    @pagy, @story_builders = pagy(StoryBuilder.includes(:questions).all)
  end

  def new
    @story_builder = StoryBuilder.new
  end

  def create
    @story_builder = StoryBuilder.new(story_builder_params)

    if @story_builder.save
      redirect_to(admin_story_builders_path, notice: "Builder created successfully!")
    else
      redirect_to(admin_story_builders_path,
        alert: "Unable to create builder. Errors: #{@story_builder.errors.full_messages.join(", ")}")
    end
  end

  def show
  end

  def edit
  end

  def update
    if @story_builder.update(story_builder_params)
      redirect_to(admin_story_builders_path, notice: "Builder updated successfully!")
    else
      redirect_to(admin_story_builder_path, alert: "Unable to update builder. Errors: #{@story_builder.errors.full_messages.join(", ")}")
    end
  end

  def destroy
    if @story_builder.destroy
      redirect_to admin_story_builders_path, notice: "Builder was successfully destroyed."
    else
      redirect_to(admin_story_builders_path(@story_builder), alert: "Unable to destroy builder. Errors: #{@story_builder.errors.full_messages.join(", ")}")
    end
  end

  private

  def story_builder_params
    params.require(:story_builder).permit(:title)
  end

  def set_story_builder
    @story_builder = StoryBuilder.find(params[:id])
  end
end
