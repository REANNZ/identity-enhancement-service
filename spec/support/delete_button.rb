# frozen_string_literal: true
# Allow Capybara tests to properly interact with aaf-lipstick's
# `delete_button_tag`
module DeleteButton
  def click_delete_button(text: 'Delete')
    button = find('div.ui.button', text: text)
    button.click
    expect(button).to have_css('.menu.visible:not(.animating)')
    click_link("Confirm #{text}")
  end
end
