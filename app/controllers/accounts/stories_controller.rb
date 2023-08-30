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

  def new
    fallback_to_registration_questions if current_user.registration_data_absence?
    @story = Story.new
  end

  private

  def set_story
    @story = Story.find(params[:id])
  end

  def fallback_to_registration_questions
    redirect_to(registration_questions_path, alert: "Please answer the registration questions before getting started!")
  end
end
