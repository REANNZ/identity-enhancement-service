# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'API Subjects Admin', js: true do
  given(:user) { create(:subject, :authorized) }

  given!(:api_subject) { create(:api_subject) }
  given(:provider) { api_subject.provider }

  given(:base_path) { "/providers/#{provider.id}" }

  background do
    attrs = create(:aaf_attributes, :from_subject, subject: user)
    RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)

    visit '/auth/login'
    click_button 'Login'

    visit '/providers'
    within('tr', text: provider.name) do
      click_link('View')
    end

    click_link('API Accounts')
    expect(current_path).to eq("#{base_path}/api_subjects")
  end

  scenario 'viewing the api subject list' do
    expect(page).to have_css('tr td', text: api_subject.x509_cn)
  end

  scenario 'editing a api subject' do
    within('tr', text: api_subject.x509_cn) do
      click_link('Edit')
    end

    expect(current_path)
      .to eq("#{base_path}/api_subjects/#{api_subject.id}/edit")
    expect(page).to have_css('.header', text: api_subject.x509_cn)

    old_cn = api_subject.x509_cn
    attrs = attributes_for(:api_subject)

    within('form') do
      fill_in 'Description', with: attrs[:description]
      fill_in 'X.509 CN', with: attrs[:x509_cn]
      fill_in 'Contact Name', with: attrs[:contact_name]
      fill_in 'Contact Email Address', with: attrs[:contact_mail]
      click_button('Save')
    end

    expect(page).to have_css('tr td', text: attrs[:x509_cn])
    expect(page).to have_no_css('tr td', text: old_cn)
  end

  scenario 'creating a api subject' do
    click_link('New API Account')

    expect(current_path).to eq("#{base_path}/api_subjects/new")

    attrs = attributes_for(:api_subject)

    within('form') do
      fill_in 'Description', with: attrs[:description]
      fill_in 'X.509 CN', with: attrs[:x509_cn]
      fill_in 'Contact Name', with: attrs[:contact_name]
      fill_in 'Contact Email Address', with: attrs[:contact_mail]
      click_button('Create')
    end

    expect(current_path).to eq("#{base_path}/api_subjects")
    expect(page).to have_css('tr td', text: attrs[:x509_cn])
  end

  scenario 'deleting a api subject' do
    within('tr', text: api_subject.x509_cn) do
      click_delete_button
    end

    expect(current_path).to eq("#{base_path}/api_subjects")
    expect(page).to have_no_css('tr td', text: api_subject.x509_cn)
  end
end
