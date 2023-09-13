class Admin::QuestionsController < Admin::ApplicationController
  before_action :set_question, only: [:show, :edit, :update, :destroy]

  def index
    @pagy, @questions = pagy(Question.includes(:story_builders).all)
  end

  def show
  end

  def new
    @question = Question.new
  end

  def create
    @question = Question.new(question_params)

    if @question.save
      redirect_to(admin_questions_path, notice: "Question created successfully!")
    else
      redirect_to(admin_questions_path, alert: "Unable to create question. Errors: #{@question.errors.full_messages.join(", ")}")
    end
  end

  def edit
  end

  def update
    if @question.update(question_params)
      redirect_to(admin_questions_path, notice: "Question updated successfully!")
    else
      redirect_to(admin_questions_path, alert: "Unable to update question. Errors: #{@question.errors.full_messages.join(", ")}")
    end
  end

  def destroy
    if @question.destroy
      redirect_to(admin_questions_path, notice: "Question was successfully destroyed.")
    else
      redirect_to(admin_questions_path, alert: "Unable to destroy question. Errors: #{@question.errors.full_messages.join(", ")}")
    end
  end

  private

  def question_params
    params.require(:question).permit(
      :title,
      prompts_attributes: [
        :id,
        :pre_text,
        :post_text,
        :_destroy
      ],
      parent_nodes_attributes: [
        :id,
        :title,
        :_destroy,
        child_nodes_attributes: [
          :id,
          :title,
          :parent_node_id,
          :_destroy
        ]
      ]
    )
  end

  def set_question
    @question = Question.find(params[:id])
  end
end
