require 'test_helper'

class Admin::BlogsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    sign_in(@admin)

    @blog = blogs(:one)
  end

  test "should get index" do
    get admin_blogs_url

    pagy = controller.instance_variable_get(:@pagy)
    blogs = controller.instance_variable_get(:@blogs)

    assert_instance_of(Pagy, pagy)
    assert_includes(blogs, @blog)
    assert_response :success
  end

  test "should get new" do
    get new_admin_blog_url
    assert_response :success
  end

  test "should create blog" do
    assert_difference('Blog.count') do
      post admin_blogs_url, params: { blog: { title: "New Blog", body: "Lorem Ipsum", published: true, tag_list: "tag1, tag2" } }
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
    patch admin_blog_url(@blog), params: { blog: { title: "Updated Title" } }
    assert_redirected_to admin_blogs_url
    assert_equal "Blog was updated successfully!", flash[:notice]
    @blog.reload
    assert_equal "Updated Title", @blog.title
  end

  test "should destroy blog" do
    assert_difference('Blog.count', -1) do
      delete admin_blog_url(@blog)
    end

    assert_redirected_to admin_blogs_url
    assert_equal "Blog was deleted successfully!", flash[:notice]
  end

  test "should share blog with accounts" do
    BlogShare.delete_all
    
    assert_difference('BlogShare.count', 1) do
      account_ids = "#{accounts(:one).id}"
      post share_admin_blog_url(@blog), params: { account_ids: account_ids }, as: :json
      
      assert_response :success
    end
  end

  test "should publish blog" do
    patch publish_admin_blog_url(@blog), as: :json

    assert_equal(JSON.parse(response.body)["published"], true)
    
    assert_response :success
  end
end
