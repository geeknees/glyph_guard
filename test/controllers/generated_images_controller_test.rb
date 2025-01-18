require "test_helper"

class GeneratedImagesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get generated_images_index_url
    assert_response :success
  end

  test "should get show" do
    get generated_images_show_url
    assert_response :success
  end

  test "should get new" do
    get generated_images_new_url
    assert_response :success
  end

  test "should get create" do
    get generated_images_create_url
    assert_response :success
  end
end
