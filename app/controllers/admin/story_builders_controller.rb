class Admin::StoryBuildersController < Admin::ApplicationController
  before_action :set_story_builder, only: [:show, :edit, :update, :destroy]

  def index
    @pagy, @story_builders = pagy(StoryBuilder.includes(:questions).all)
  end

  def new
    @story_builder = StoryBuilder.new
    @pagy, @questions = pagy(Question.all, items: 30)
    @tracked_question_ids = []
  end

  def create
    @story_builder = StoryBuilder.new(story_builder_params)

    if @story_builder.save
      attach_questions_to_builder
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
    @tracked_question_ids = @story_builder.questions&.pluck(:id)
  end

  def update
    @tracked_question_ids = @story_builder.questions&.pluck(:id)

    if @story_builder.update(story_builder_params)
      attach_questions_to_builder
      detach_questions_from_builder
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

  def is_question_id_tracked?(id)
    return false if action_name == "create"
    @tracked_question_ids.include?(id)
  end

  def attach_questions_to_builder
    questionnaire_data = params[:builder][:q_ids].compact_blank.map do |id|
      {question_id: id, story_builder_id: @story_builder.id} unless is_question_id_tracked?(id.to_i)
    end

    questionnaire_data.compact!
    Questionnaire.insert_all(questionnaire_data) if questionnaire_data.present?
  end

  def detach_questions_from_builder
    q_ids_to_be_deleted = []
    supplied_q_ids = params[:builder][:q_ids].compact_blank

    # if already tracked questions ids are not present in q_ids
    @tracked_question_ids.each { |id| q_ids_to_be_deleted << id unless supplied_q_ids.include?(id.to_s) }

    # Query the questionnaires and delete them
    Questionnaire.where(question_id: q_ids_to_be_deleted).delete_all if q_ids_to_be_deleted.present?
  end
end
