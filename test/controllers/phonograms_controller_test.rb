require "test_helper"

class PhonogramsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @phonogram = phonograms(:one)
  end

  test "should get index" do
    get phonograms_url
    assert_response :success
  end

  test "should get new" do
    get new_phonogram_url
    assert_response :success
  end

  test "should create phonogram" do
    assert_difference('Phonogram.count') do
      post phonograms_url, params: { phonogram: { data: @phonogram.data } }
    end

    assert_redirected_to phonogram_url(Phonogram.last)
  end

  test "should show phonogram" do
    get phonogram_url(@phonogram)
    assert_response :success
  end

  test "should get edit" do
    get edit_phonogram_url(@phonogram)
    assert_response :success
  end

  test "should update phonogram" do
    patch phonogram_url(@phonogram), params: { phonogram: { data: @phonogram.data } }
    assert_redirected_to phonogram_url(@phonogram)
  end

  test "should destroy phonogram" do
    assert_difference('Phonogram.count', -1) do
      delete phonogram_url(@phonogram)
    end

    assert_redirected_to phonograms_url
  end
end
