class Accounts::StoriesController < Accounts::BaseController
  before_action :authenticate_user!
  before_action :set_story, only: [:show, :edit, :update, :destroy, :update_visibility, :final_version, :publish]
  before_action :set_account, only: :update_visibility
  before_action :require_account_admin, only: :update_visibility
  before_action :is_story_published, only: :edit

  def index
    # Fetch organization stories that are shared by the organization admin
    org_stories = current_account.stories.includes(:story_builder, :creator).publicized.order(updated_at: :desc)
    @admin_logged_in = current_account_user.roles.include?("admin")
    @pagy_1, @org_stories = pagy(@admin_logged_in ? org_stories : org_stories.viewable, items: 10)

    # Fetch stories that are created by the logged in organization admin/member
    @pagy_2, @my_stories = pagy(Story.includes(:story_builder, :creator).where(creator_id: current_user.id).order(updated_at: :desc), items: 10)
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
    @my_stories = Story.where(creator_id: current_user.id).limit(5)
    @questions = @story.story_builder.questions.active
    @active_positions = @questions.pluck(:position).sort.join(",")

    if @questions.empty?
      redirect_to(account_stories_path(current_account), alert: "Your chosen story builder has no associated questions!")
    else
      @question = @questions.order(position: :asc).first
      question_answers = @question.answers
      @answer = question_answers&.find_by(story_id: @story.id)&.response
      @prompts = @question.prompts.order(position: :asc)
      @nodes = @question.parent_nodes
      @prompt = @prompts.first
      @selectors = question_answers.where(story_id: @story.id, prompt_id: @prompt.id)&.pluck(:response) if @prompt.present?
      @prompt_pre_text, @prompt_post_text = parse_prompt_title(@story.id) if @prompt.present?

      @prompt_mode = @prompts.any? ? "on" : "off"
      @ai_content_mode = @question.ai_prompt_attached ? "on" : "off"
      @only_node_mode = (@prompt_mode == "off" && @nodes.present?) ? "on" : "off"

      if @prompt_mode == "on"
        @renderer = "wrap_prompts_container"
      elsif @prompt_mode == "off"
        @renderer = if @only_node_mode == "on"
          "nodes_prompts_container"
        else
          "without_nodes_prompts_container"
        end
      end
    end
  end

  def update
    respond_to do |format|
      format.json do
        if params[:change_access_mode] == "on"
          @story.toggle!(:private_access)

          render json: {private_access: @story.private_access, operation: "change_access_mode"}
        elsif params[:draft_mode] == "on"
          @story.draft!
          render json: {status: @story.status.to_s, operation: "draft_mode"}
        else
          create_story_version(reset_old: true)
          render json: {url: final_version_path(@story.id)}
        end
      end

      format.html do
        create_story_version(reset_old: false)
        redirect_to(final_version_path(@story.id), notice: "Enhancing the story with a new version!")
      end
    end
  end

  def question_navigation
    story_builder = StoryBuilder.find(params[:story_builder_id])
    @question = story_builder.questions.active.find_by(position: params[:position].to_i)

    respond_to do |format|
      format.json do
        if @question.nil?
          render json: {question_id: nil, question_title: nil, success: false}
        else
          render json: {
            question_id: @question.id,
            question_title: @question.title,
            ai_mode: @question.ai_prompt_attached,
            multiple_node_selection_mode: @question.multiple_node_selection,
            success: true
          }
        end
      end
    end
  end

  def prompt_navigation
    question = Question.find(params[:id])
    index = params[:index].to_i + 1
    @prompts = question.prompts
    @prompt = question.prompts.find_by(position: index)
    @prompt_pre_text, @prompt_post_text = parse_prompt_title(params[:story_id]) if @prompt.present?
    question_answers = question.answers
    answer_response = question_answers&.find_by(story_id: params[:story_id])&.response if params[:story_id].present?
    ai_content_mode = question.ai_prompt_attached ? "on" : "off"

    if params[:story_id].present? && @prompt.present?
      @selectors = question_answers.where(story_id: params[:story_id], prompt_id: @prompt.id)&.pluck(:response)
    end

    node_selection = build_node_selection_structure(question.parent_nodes)

    respond_to do |format|
      format.json do
        if @prompt.nil?
          if node_selection.empty?
            render json: {
              html: render_to_string(partial: "display_question_content", locals: {
                                                                            renderer: "without_nodes_prompts_container",
                                                                            ai_content_mode: ai_content_mode,
                                                                            only_node_mode: "off",
                                                                            prompt_mode: "off",
                                                                            prompts: @prompts,
                                                                            prompt: @prompt,
                                                                            prompt_pretext: @prompt_pre_text,
                                                                            prompt_posttext: @prompt_post_text,
                                                                            selectors: @selectors,
                                                                            nodes: question.parent_nodes,
                                                                            multiple_selection_mode: question.multiple_node_selection,
                                                                            answer: answer_response
                                                                          },
                formats: [:html]),
              nodes_without_prompt: false,
              prompt_id: nil,
              prompt_pretext: nil,
              prompt_posttext: nil,
              count: nil,
              answer: answer_response,
              success: false
            }
          else
            render json: {
              html: render_to_string(partial: "display_question_content", locals: {
                                                                            renderer: "nodes_prompts_container",
                                                                            ai_content_mode: ai_content_mode,
                                                                            only_node_mode: "on",
                                                                            prompt_mode: "off",
                                                                            prompts: @prompts,
                                                                            prompt: @prompt,
                                                                            prompt_pretext: @prompt_pre_text,
                                                                            prompt_posttext: @prompt_post_text,
                                                                            selectors: @selectors,
                                                                            nodes: question.parent_nodes,
                                                                            multiple_selection_mode: question.multiple_node_selection,
                                                                            answer: answer_response
                                                                          },
                formats: [:html]),
              nodes_without_prompt: true,
              nodes: node_selection,
              answer: answer_response,
              success: true
            }
          end
        else
          render json: {
            html: render_to_string(partial: "display_question_content", locals: {
                                                                          renderer: "wrap_prompts_container",
                                                                          ai_content_mode: ai_content_mode,
                                                                          only_node_mode: "off",
                                                                          prompt_mode: "on",
                                                                          prompts: @prompts,
                                                                          prompt: @prompt,
                                                                          prompt_pretext: @prompt_pre_text,
                                                                          prompt_posttext: @prompt_post_text,
                                                                          selectors: @selectors,
                                                                          nodes: question.parent_nodes,
                                                                          multiple_selection_mode: question.multiple_node_selection,
                                                                          answer: answer_response
                                                                        },
              formats: [:html]),
            nodes_without_prompt: false,
            prompt_id: @prompt.id,
            prompt_pretext: @prompt_pre_text,
            prompt_posttext: @prompt_post_text,
            prompt_selector: @prompt.selector,
            count: question.prompts.count,
            nodes: node_selection,
            success: true
          }
        end
      end
    end
  end

  # GET stories/:story_builder_id/question/:id/nodes
  def question_nodes
    story_builder = StoryBuilder.find(params[:story_builder_id])
    question = story_builder.questions.find(params[:id])
    @parent_nodes = question.parent_nodes.map { |node| [node.title, node.id] }

    respond_to do |format|
      format.json do
        render json: {parent_nodes: @parent_nodes, success: true}
      end
    end
  end

  # GET /question/:id/nodes/:node_id/child_nodes
  def sub_nodes_per_node
    question = Question.find(params[:id])
    node = question.parent_nodes.find(params[:node_id])
    @child_nodes = node.child_nodes.map { |node| [node.title, node.id] }

    respond_to do |format|
      format.json do
        render json: {child_nodes: @child_nodes, success: true}
      end
    end
  end

  def track_answers
    question = Question.find(params[:id])
    prompt = Prompt.find_by(id: params[:prompt_id])
    answers = []
    success = true

    selectors = if params[:ai_mode] == "on"
      [params[:selector]]
    else
      params[:selector].split(",")
    end

    selectors.each do |selector|
      answers << track_answer_as_per_prompt(question, prompt, selector)
    end

    answers.each do |answer|
      if answer.save
        prompt.update(selector: params[:selector]) if prompt.present?
      else
        success = false
      end
    end

    remove_detached_answers(question.answers, selectors)

    if params[:cursor] == "undefined"
      question_title = question.title
    else
      story = Story.find_by(id: answers.first.story_id)

      if story.present?
        next_position = (params[:cursor] == "backward") ? question.position - 1 : question.position + 1
        next_position += 1 if next_position == 0
        next_question = story.story_builder.questions.find_by(position: next_position)
        question_title = AiDataParser.new(story_id: answers.first.story_id, data: next_question.title).parse
      end
    end

    respond_to do |format|
      format.json do
        render json: {answers: answers, next_question_title: question_title, success: success}
      end
    end
  end

  def update_visibility
    respond_to do |format|
      format.json do
        if @story.toggle!(:viewable)
          render json: {viewable: @story.viewable, success: true}
        else
          render json: {viewable: nil, success: false}
        end
      end
    end
  end

  def ai_based_questions_content
    question = Question.find(params[:question_id])

    dynamic_content = AiDataParser.new(
      story_id: params[:story_id],
      data: question.ai_prompt
    ).parse

    AiContentCreatorJob.perform_later({
      current_user: current_user,
      content: dynamic_content
    })

    respond_to do |format|
      format.json do
        render json: {
          success: true
        }
      end
    end
  end

  def final_version
    @my_stories = Story.where(creator_id: current_user.id).limit(5)
    @response_generated = @story.ai_generated_content.present?
  end

  def publish
    @story.published!
    redirect_to(account_stories_path(current_account.id), notice: "Story published successfully!")
  end

  private

  def story_params
    params.require(:story).permit(:title, :story_builder_id)
  end

  def set_story
    @story = Story.find(params[:id])
  end

  def set_account
    @account = current_account
  end

  def is_story_published
    redirect_to(account_stories_path(current_account), alert: "Story has already been published!") if @story.published?
  end

  def track_answer_as_per_prompt(question, prompt, selector)
    prompt.present? ?
      question.answers.find_or_initialize_by(story_id: params[:story_id], prompt_id: prompt.id, response: selector) :
      question.answers.find_or_initialize_by(story_id: params[:story_id], response: selector)
  end

  def remove_detached_answers(answers, selectors)
    answers.each do |answer|
      answer.destroy unless selectors.include?(answer.response)
    end
  end

  def build_node_selection_structure(parent_nodes)
    node_selection = []

    parent_nodes.each do |node|
      node_hash = {}
      child_nodes_data = []
      node.child_nodes.each do |child_node|
        child_nodes_data << {id: child_node.id, title: child_node.title}
      end
      node_hash[:id] = node.id
      node_hash[:title] = node.title
      node_hash[:child_nodes] = child_nodes_data
      node_selection << node_hash
    end

    node_selection
  end

  def create_story_version(reset_old:)
    @story.complete! unless params[:request_new_version].present?

    @story.update(ai_generated_content: nil) if reset_old

    dynamic_prompt = AiDataParser.new(story_id: @story.id, data: @story.story_builder.admin_ai_prompt).parse
    StoryCreatorJob.perform_later({
      current_user: current_user,
      story: @story,
      admin_ai_prompt: dynamic_prompt
    })
  end

  def parse_prompt_title(story_id)
    parsed_data = []

    [@prompt.pre_text, @prompt.post_text].each do |data_element|
      parsed_data << AiDataParser.new(story_id: story_id, data: data_element).parse
    end

    parsed_data
  end
end
