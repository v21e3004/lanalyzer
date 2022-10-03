require 'test_helper'

class TimetablesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get timetables_new_url
    assert_response :success
  end

end
