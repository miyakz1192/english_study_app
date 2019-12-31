require "application_system_test_case"

class ScoreEngNotWrittensTest < ApplicationSystemTestCase
  setup do
    @score_eng_not_written = score_eng_not_writtens(:one)
  end

  test "visiting the index" do
    visit score_eng_not_writtens_url
    assert_selector "h1", text: "Score Eng Not Writtens"
  end

  test "creating a Score eng not written" do
    visit score_eng_not_writtens_url
    click_on "New Score Eng Not Written"

    click_on "Create Score eng not written"

    assert_text "Score eng not written was successfully created"
    click_on "Back"
  end

  test "updating a Score eng not written" do
    visit score_eng_not_writtens_url
    click_on "Edit", match: :first

    click_on "Update Score eng not written"

    assert_text "Score eng not written was successfully updated"
    click_on "Back"
  end

  test "destroying a Score eng not written" do
    visit score_eng_not_writtens_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Score eng not written was successfully destroyed"
  end
end
