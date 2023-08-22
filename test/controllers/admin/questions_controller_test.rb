require "test_helper"

class Admin::QuestionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:admin)
    sign_in(@admin)
  end

  test "should get index" do
    get admin_questions_path
    assert_response :success
  end

  test "should get show" do
    question = questions(:one)
    get admin_question_path(question)
    assert_response :success
  end

  test "should get new" do
    get new_admin_question_path
    assert_response :success
  end

  test "should create question" do
    prompts_count_before = Prompt.count
    # parent_nodes_count_before = ParentNode.count

    # TODO: Fix the ParentNode.count inconsistency

    # puts Prompt.count
    # puts ParentNode.count

    # puts ParentNode.all.inspect
    # puts ChildNode.count

    # puts "_____________"

    post admin_questions_path, params: {
      question: {
        title: "New Question",
        prompts_attributes: [{pre_text: "Pre", post_text: "Post"}],
        parent_nodes_attributes: [
          {title: "Parent Node", child_nodes_attributes: [{title: "Child Node"}]}
        ]
      }
    }

    # puts Prompt.count
    # puts ParentNode.count

    # puts ParentNode.all.inspect
    # puts ChildNode.count

    assert_redirected_to admin_questions_path
    assert_equal "Question created successfully!", flash[:notice]
    assert_equal prompts_count_before + 1, Prompt.count
    # assert_equal parent_nodes_count_before + 1, ParentNode.count
  end

  test "should get edit" do
    question = questions(:one)
    get edit_admin_question_path(question)
    assert_response :success
  end

  test "should update question" do
    question = questions(:one)
    patch admin_question_path(question), params: {
      question: {title: "Updated Title"}
    }

    assert_redirected_to admin_questions_path
    assert_equal "Question updated successfully!", flash[:notice]
    question.reload
    assert_equal "Updated Title", question.title
  end

  test "should destroy question" do
    question = questions(:one)
    prompts_count_before = Prompt.count
    # parent_nodes_count_before = ParentNode.count

    delete admin_question_path(question)

    assert_redirected_to admin_questions_path
    assert_equal "Question was successfully destroyed.", flash[:notice]
    assert_equal prompts_count_before - 1, Prompt.count
    # assert_equal parent_nodes_count_before - 1, ParentNode.count
  end
end
