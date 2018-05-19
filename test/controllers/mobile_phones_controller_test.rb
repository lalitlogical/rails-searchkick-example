require 'test_helper'

class MobilePhonesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @mobile_phone = mobile_phones(:one)
  end

  test "should get index" do
    get mobile_phones_url
    assert_response :success
  end

  test "should get new" do
    get new_mobile_phone_url
    assert_response :success
  end

  test "should create mobile_phone" do
    assert_difference('MobilePhone.count') do
      post mobile_phones_url, params: { mobile_phone: {  } }
    end

    assert_redirected_to mobile_phone_url(MobilePhone.last)
  end

  test "should show mobile_phone" do
    get mobile_phone_url(@mobile_phone)
    assert_response :success
  end

  test "should get edit" do
    get edit_mobile_phone_url(@mobile_phone)
    assert_response :success
  end

  test "should update mobile_phone" do
    patch mobile_phone_url(@mobile_phone), params: { mobile_phone: {  } }
    assert_redirected_to mobile_phone_url(@mobile_phone)
  end

  test "should destroy mobile_phone" do
    assert_difference('MobilePhone.count', -1) do
      delete mobile_phone_url(@mobile_phone)
    end

    assert_redirected_to mobile_phones_url
  end
end
