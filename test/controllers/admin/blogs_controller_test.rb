require "test_helper"

class Admin::BlogsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    sign_in(@admin)

    @blog = blogs(:one)
  end

  test "should get index" do
    # get accounts_blogs_url

    # featured_blogs = controller.instance_variable_get(:@featured_blogs)
    # recent_blogs = controller.instance_variable_get(:@recent_blogs)
    
    # assert_instance_of(ActiveRecord::Relation, featured_blogs)
    # assert_instance_of(ActiveRecord::Relation, recent_blogs)
    # assert_includes(featured_blogs, @blog)
    # assert_includes(recent_blogs, @blog)
    # assert_response :success
  end

  test "should get new" do
    get new_admin_blog_url
    assert_response :success
  end

  test "should create blog" do
    assert_difference("Blog.count") do
      post admin_blogs_url, params: {blog: {title: "New Blog", body: "Lorem Ipsum", published: true, tag_list: "tag1, tag2"}, account_ids: accounts(:one).id.to_s}
    end

    assert_redirected_to admin_blogs_url
    assert_equal "Blog was created successfully!", flash[:notice]
  end

  test "should show blog" do
    get admin_blog_url(@blog)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_blog_url(@blog)
    assert_response :success
  end

  test "should update blog" do
    patch admin_blog_url(@blog), params: {blog: {title: "Updated Title"}, account_ids: accounts(:two).id.to_s}
    assert_redirected_to admin_blogs_url
    assert_equal "Blog was updated successfully!", flash[:notice]
    @blog.reload
    assert_equal "Updated Title", @blog.title
  end

  test "should destroy blog" do
    assert_difference("Blog.count", -1) do
      delete admin_blog_url(@blog)
    end

    assert_redirected_to admin_blogs_url
    assert_equal "Blog was deleted successfully!", flash[:notice]
  end

  test "should publish blog" do
    patch publish_admin_blog_url(@blog), as: :json

    assert_equal(JSON.parse(response.body)["published"], true)

    assert_response :success
  end
end
