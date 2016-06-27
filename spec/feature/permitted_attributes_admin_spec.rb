# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Permitted attributes admin', js: true do
  given(:user) { create(:subject, :authorized) }

  given!(:permitted_attribute) { create(:permitted_attribute) }
  given!(:provider) { permitted_attribute.provider }
  given!(:attribute) { permitted_attribute.available_attribute }
  given!(:other_attribute) { create(:available_attribute) }

  given(:base_path) { "/admin/providers/#{provider.id}" }

  background do
    attrs = create(:aaf_attributes, :from_subject, subject: user)
    RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)

    visit '/auth/login'
    click_button 'Login'

    visit '/providers'
    within('tr', text: provider.name) do
      click_link('View')
    end

    click_link('Permitted Attributes')
    expect(current_path).to eq("#{base_path}/permitted_attributes")
  end

  scenario 'viewing the attribute list' do
    expect(page).to have_css('#permitted tr td', text: attribute.value)
    expect(page).to have_no_css('#permitted tr td',
                                text: other_attribute.value)

    expect(page).to have_no_css('#available tr td', text: attribute.value)
    expect(page).to have_css('#available tr td', text: other_attribute.value)
  end

  scenario 'adding a permitted attribute' do
    within('#available tr', text: other_attribute.value) do
      click_button('Add')
    end

    expect(page).to have_css('#permitted tr td', text: other_attribute.value)
    expect(current_path).to eq("#{base_path}/permitted_attributes")
  end

  scenario 'removing a permitted attribute' do
    within('#permitted tr', text: attribute.value) do
      click_delete_button(text: 'Remove')
    end

    expect(page).to have_no_css('#permitted tr td', text: attribute.value)
    expect(page).to have_css('#available tr td', text: attribute.value)
    expect(current_path).to eq("#{base_path}/permitted_attributes")
  end
end
