class StoryBuildersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_story_builder, only: [:show, :edit, :update, :destroy]

  def index
    @pagy, @story_builders = pagy(StoryBuilder.all)
    @redirect_to_registration_section = current_user.registration_data_absence?
    @story = Story.new
  end

  private

  def set_story_builder
    @story_builder = StoryBuilder.find(params[:id])
  end
end
