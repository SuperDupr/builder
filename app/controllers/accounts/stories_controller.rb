class Accounts::StoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_story, only: [:show, :edit, :update, :destroy]

  def index
    # Fetch organization stories that are shared by the organization admin
    org_stories = current_account.stories.includes(:story_builder).publicized
    @pagy_1, @org_stories = pagy(current_account_user.roles.include?("admin") ? org_stories : org_stories.viewable)

    # Fetch stories that are created by the logged in organization admin/member
    @pagy_2, @my_stories = pagy(Story.includes(:story_builder).where(creator_id: current_user.id))
  end

  def create
    @story = current_account.stories.new(story_params)
    @story.creator_id = current_user.id

    if @story.save
      redirect_to(edit_account_story_path(@story, account_id: current_account.id), notice: "Your story has been created!")
    else
      redirect_to(story_builders_path, alert: "Unable to create story. Errors: #{@story.errors.full_messages.join(", ")}")
    end
  end

  def edit
  end

  private

  def story_params
    params.require(:story).permit(:title, :story_builder_id)
  end

  def set_story
    @story = Story.find(params[:id])
  end
end
