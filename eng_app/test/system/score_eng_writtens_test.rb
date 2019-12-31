require "application_system_test_case"

class ScoreEngWrittensTest < ApplicationSystemTestCase
  setup do
    @score_eng_written = score_eng_writtens(:one)
  end

  test "visiting the index" do
    visit score_eng_writtens_url
    assert_selector "h1", text: "Score Eng Writtens"
  end

  test "creating a Score eng written" do
    visit score_eng_writtens_url
    click_on "New Score Eng Written"

    click_on "Create Score eng written"

    assert_text "Score eng written was successfully created"
    click_on "Back"
  end

  test "updating a Score eng written" do
    visit score_eng_writtens_url
    click_on "Edit", match: :first

    click_on "Update Score eng written"

    assert_text "Score eng written was successfully updated"
    click_on "Back"
  end

  test "destroying a Score eng written" do
    visit score_eng_writtens_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Score eng written was successfully destroyed"
  end
end
