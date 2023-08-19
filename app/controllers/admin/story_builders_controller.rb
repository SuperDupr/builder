class Admin::StoryBuildersController < Admin::ApplicationController
  before_action :set_story_builder, only: [:show, :edit, :update, :destroy]

  def index
    @pagy, @story_builders = pagy(StoryBuilder.includes(:questions).all)
  end

  def new
    @story_builder = StoryBuilder.new
    @pagy, @questions = pagy(Question.all, items: 30)
  end

  def create
    @story_builder = StoryBuilder.new(story_builder_params)

    if @story_builder.save
      questionnaire_data = params[:builder][:q_ids].compact_blank.map { |id| {question_id: id, story_builder_id: @story_builder.id} }
      Questionnaire.insert_all(questionnaire_data) if questionnaire_data.present?
      redirect_to(admin_story_builders_path, notice: "Builder created successfully!")
    else
      redirect_to(admin_story_builders_path,
        alert: "Unable to create builder. Errors: #{@story_builder.errors.full_messages.join(", ")}")
    end
  end

  def show
  end

  def edit
    @pagy, @questions = pagy(Question.all, items: 30)
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
      redirect_to(admin_story_builders_path, alert: "Unable to destroy builder. Errors: #{@story_builder.errors.full_messages.join(", ")}")
    end
  end

  private

  def story_builder_params
    params.require(:story_builder).permit(:title, q_ids: [])
  end

  def set_story_builder
    @story_builder = StoryBuilder.find(params[:id])
  end
end
