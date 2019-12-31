require 'test_helper'

class ScoreEngNotWrittensControllerTest < ActionDispatch::IntegrationTest
  setup do
    @score_eng_not_written = score_eng_not_writtens(:one)
  end

  test "should get index" do
    get score_eng_not_writtens_url
    assert_response :success
  end

  test "should get new" do
    get new_score_eng_not_written_url
    assert_response :success
  end

  test "should create score_eng_not_written" do
    assert_difference('ScoreEngNotWritten.count') do
      post score_eng_not_writtens_url, params: { score_eng_not_written: {  } }
    end

    assert_redirected_to score_eng_not_written_url(ScoreEngNotWritten.last)
  end

  test "should show score_eng_not_written" do
    get score_eng_not_written_url(@score_eng_not_written)
    assert_response :success
  end

  test "should get edit" do
    get edit_score_eng_not_written_url(@score_eng_not_written)
    assert_response :success
  end

  test "should update score_eng_not_written" do
    patch score_eng_not_written_url(@score_eng_not_written), params: { score_eng_not_written: {  } }
    assert_redirected_to score_eng_not_written_url(@score_eng_not_written)
  end

  test "should destroy score_eng_not_written" do
    assert_difference('ScoreEngNotWritten.count', -1) do
      delete score_eng_not_written_url(@score_eng_not_written)
    end

    assert_redirected_to score_eng_not_writtens_url
  end
end
