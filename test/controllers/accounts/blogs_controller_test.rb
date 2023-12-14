require "test_helper"

class Accounts::BlogsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    sign_in(@user)

    @account = accounts(:one)
    @blog = blogs(:one)
  end

  test "should get index" do
    @account.blog_shares.create(blog_id: @blog.id)
    get account_blogs_url(@account)

    pagy = controller.instance_variable_get(:@pagy)
    blogs = controller.instance_variable_get(:@blogs)

    assert_instance_of(Pagy, pagy)
    assert_includes(blogs, @blog)

    assert_response :success
  end

  test "should get show" do
    get account_blog_url(@blog, account_id: @account.id)
    
    assert_response :success
  end
end
