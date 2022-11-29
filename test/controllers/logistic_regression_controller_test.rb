require 'test_helper'

class LogisticRegressionControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get logistic_regression_index_url
    assert_response :success
  end

end
