require "test_helper"

class Accounts::StoriesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    sign_in(@user)

    @account = accounts(:one)
    @story = stories(:one)
  end

  test "should get index" do
    @account.stories << @story
    get account_stories_path(account_id: @account.id)

    admin_logged_in = controller.instance_variable_get(:@admin_logged_in)
    pagy_1 = controller.instance_variable_get(:@pagy_1)
    org_stories = controller.instance_variable_get(:@org_stories)
    my_stories = controller.instance_variable_get(:@my_stories)

    assert_equal(admin_logged_in, true)
    assert_instance_of(Pagy, pagy_1)
    assert_includes(org_stories, @story)
    assert_includes(my_stories, @story)

    assert_response(:success)
  end

  test "should create story" do
    story_builder = story_builders(:one)

    assert_difference("Story.count") do
      post account_stories_path(account_id: @account.id), params: {
        story: {
          title: "New Story",
          story_builder_id: story_builder.id
        }
      }
    end

    story = controller.instance_variable_get(:@story)

    assert_redirected_to edit_account_story_path(story, account_id: @account.id)
  end

  test "should edit story" do
    @story.story_builder.questions << questions(:one)
    @account.stories << @story

    get edit_account_story_path(@story.id, account_id: @account.id)

    questions = controller.instance_variable_get(:@questions)
    question = controller.instance_variable_get(:@question)
    answer = controller.instance_variable_get(:@answer)

    assert_not_empty(questions)
    assert_equal(question.id, questions(:one).id)
    assert_nil(answer)
    assert_response :success
  end

  test "should update story" do
    patch account_story_path(@story, account_id: @account.id), params: {
      change_access_mode: "on"
    }, xhr: true

    # assert_response :success
    # assert_equal(JSON.parse(response.body)["private_access"], true)

    patch account_story_path(@story, account_id: @account.id), params: {
      draft_mode: "on"
    }, xhr: true

    # assert_response :success
    # assert_equal(JSON.parse(response.body)["status"], "draft")
  end

  test "should update story (HTML format)" do
    patch account_story_path(@story, account_id: @account.id)

    enqueued_job = ActiveJob::Base.queue_adapter.enqueued_jobs.first

    assert_equal(@story.complete?, true)
    assert_equal(enqueued_job["job_class"], "StoryCreatorJob")
    assert_enqueued_jobs(1)
    assert_response(:redirect)
  end

  test "should navigate to a question" do
    story_builder = @story.story_builder
    story_builder.questions << questions(:one)
    question = story_builder.questions.first

    get question_navigation_path(story_builder.id), params: {story_id: @story.id, position: 1}, xhr: true

    assert_equal(JSON.parse(response.body)["question_title"], question.title)
    assert_response :success
  end

  test "should navigate to a prompt" do
    question = questions(:one)

    prompt = question.prompts.first
    get prompt_navigation_path(question.id), params: {index: 0, story_id: @story.id}, xhr: true

    assert_equal(JSON.parse(response.body)["prompt_pretext"], prompt.pre_text)
    assert_response :success
  end

  test "should get question nodes" do
    story_builder = story_builders(:one)
    question = questions(:one)
    story_builder.questions << question
    question_parent_node = question.parent_nodes.create!(title: "Node 1")

    get question_nodes_path(question.id, story_builder_id: story_builder.id), xhr: true

    assert_includes(JSON.parse(response.body)["parent_nodes"].flatten.first, question_parent_node.title)
    assert_response :success
  end

  test "should get sub nodes per node" do
    question = questions(:one)
    parent_node = question.parent_nodes.create!(title: "Parent Node 1")
    child_node = parent_node.child_nodes.create!(title: "Child Node 1")

    get child_nodes_per_node_path(question.id, node_id: parent_node.id), xhr: true

    assert_includes(JSON.parse(response.body)["child_nodes"].flatten.first, child_node.title)
    assert_response :success
  end

  test "should track answers" do
    question = questions(:one)
    prompt = question.prompts.first

    @story.story_builder.questions << question
    @story.story_builder.questions << questions(:two)

    post track_answers_path(question.id), params: {prompt_id: prompt.id, story_id: @story.id, selector: "selected_option"}, xhr: true

    assert_equal(JSON.parse(response.body)["answers"][0]["id"].present?, true)

    assert_response :success
  end

  test "should update visibility" do
    patch update_visibility_path(@story.id), xhr: true

    assert_equal(JSON.parse(response.body)["viewable"], !@story.viewable)
    assert_response :success
  end

  test "should generate content" do
    @story.update(ai_generated_content: "Instructions for GPT-4")
    get final_version_path(@story)

    my_stories = controller.instance_variable_get(:@my_stories)
    response_generated = controller.instance_variable_get(:@response_generated)

    assert_includes(my_stories, @story)
    assert_equal(response_generated, true)
    assert_response(:success)
  end

  test "should publish story" do
    patch publish_story_path(@story)

    assert_equal(@story.reload.published?, true)
    assert_response(:redirect)
  end
end
