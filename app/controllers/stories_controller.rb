class StoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_story, only: [:show, :edit, :update, :destroy]

  def index
  end
  
  def new
    @story = Story.new
  end

  private

  def set_story
    @story = Story.find(params[:id])    
  end
end
