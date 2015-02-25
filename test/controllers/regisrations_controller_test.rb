require 'test_helper'

class RegisrationsControllerTest < ActionController::TestCase
  test "should get create" do
    get :create
    assert_response :success
  end

  test "should get sign_up" do
    get :sign_up
    assert_response :success
  end

end
