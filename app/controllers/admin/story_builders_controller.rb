class Admin::StoryBuildersController < Admin::ApplicationController
  before_action :set_story_builder, only: [:show, :edit, :update, :destroy, :sort_questions]

  def index
    @pagy, @story_builders = pagy(StoryBuilder.includes(:questions).all)
  end

  def new
    @story_builder = StoryBuilder.new
    @pagy, @questions = pagy(@story_builder.questions, items: 30)
    @tracked_question_ids = []
  end

  def create
    @story_builder = StoryBuilder.new(story_builder_params)

    if @story_builder.save
      handle_redirect_behaviour
    else
      redirect_to(admin_story_builders_path,
        alert: "Unable to create builder. Errors: #{@story_builder.errors.full_messages.join(", ")}")
    end
  end

  def show
    @questions = @story_builder.questions.order(position: :asc)
    @questions_size = @questions.size
  end

  def edit
    @pagy, @questions = pagy(@story_builder.questions.sort_by_position, items: 30)
    @tracked_question_ids = @story_builder.questions.active&.pluck(:id)
  end

  def update
    @tracked_question_ids = @story_builder.questions.active&.pluck(:id)

    if @story_builder.update(story_builder_params)
      handle_redirect_behaviour
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

  def sort_questions
    question = @story_builder.questions.find(params[:question_id])

    respond_to do |format|
      format.json do
        if question.update(position: params[:question][:position].to_i)
          render json: {success: true, question: question}
        else
          render json: {success: false, question: nil}
        end
      end
    end
  end

  private

  def story_builder_params
    params.require(:story_builder).permit(:title, :admin_ai_prompt, q_ids: [])
  end

  def set_story_builder
    @story_builder = StoryBuilder.find(params[:id])
  end

  def questions_exist?
    params[:builder].present? && params[:builder][:q_ids].present?
  end

  def tweak_questions_status
    supplied_q_ids = params[:builder][:q_ids].compact_blank

    @story_builder.questions.where(id: supplied_q_ids).update_all(active: true)
    @story_builder.questions.where.not(id: supplied_q_ids).update_all(active: false)
  end

  def handle_redirect_behaviour
    if params[:save_builder_and_add_question]
      redirect_to(new_admin_question_path(fallback_builder_id: @story_builder.id))
    else
      if action_name == "update"
        if questions_exist?
          tweak_questions_status
        end
      end

      redirect_to(admin_story_builders_path, notice: "Builder saved successfully!")
    end
  end
end
