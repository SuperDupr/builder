class StoryBuildersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_story_builder, only: [:show, :edit, :update, :destroy]

  def index
    @pagy, @story_builders = pagy(StoryBuilder.all)    
  end

  private

  def set_story_builder
    @story_builder = StoryBuilder.find(params[:id])
  end
end
