require "application_system_test_case"

class PhonogramsTest < ApplicationSystemTestCase
  setup do
    @phonogram = phonograms(:one)
  end

  test "visiting the index" do
    visit phonograms_url
    assert_selector "h1", text: "Phonograms"
  end

  test "creating a Phonogram" do
    visit phonograms_url
    click_on "New Phonogram"

    fill_in "Data", with: @phonogram.data
    click_on "Create Phonogram"

    assert_text "Phonogram was successfully created"
    click_on "Back"
  end

  test "updating a Phonogram" do
    visit phonograms_url
    click_on "Edit", match: :first

    fill_in "Data", with: @phonogram.data
    click_on "Update Phonogram"

    assert_text "Phonogram was successfully updated"
    click_on "Back"
  end

  test "destroying a Phonogram" do
    visit phonograms_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Phonogram was successfully destroyed"
  end
end
