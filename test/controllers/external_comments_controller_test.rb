require "test_helper"

class ExternalCommentsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get external_comments_create_url
    assert_response :success
  end

  test "should get destroy" do
    get external_comments_destroy_url
    assert_response :success
  end
end
