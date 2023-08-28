class Accounts::StoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_story, only: [:show, :edit, :update, :destroy]

  def index
    # Fetch organization stories that are shared by the organization admin
    org_stories = current_account.stories.includes(:story_builder).publicized
    @org_stories = current_account_user.roles.include?("admin") ? org_stories : org_stories.viewable

    # Fetch stories that are created by the logged in organization admin/member
    @my_stories = Story.includes(:story_builder).where(creator_id: current_user.id)
  end

  def new
    @story = Story.new
  end

  private

  def set_story
    @story = Story.find(params[:id])
  end
end
