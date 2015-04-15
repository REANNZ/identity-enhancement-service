require 'rails_helper'

RSpec.feature 'Modifying Providers', js: true do
  given(:user) { create(:subject, :authorized) }
  given!(:provider) { create(:provider) }

  background do
    attrs = create(:aaf_attributes, :from_subject, subject: user)
    RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)

    visit '/auth/login'
    click_button 'Login'
  end

  scenario 'viewing the providers list' do
    visit '/providers'
    expect(current_path).to eq('/providers')

    expect(page).to have_css('table tr td', text: provider.name)
  end

  scenario 'viewing a provider' do
    visit '/providers'
    within('table tr', text: provider.name) do
      click_link 'View'
    end

    expect(page).to have_content(provider.name)
    expect(page).to have_content(provider.identifier)
  end

  scenario 'creating a provider' do
    visit '/providers'
    click_link 'New Provider'

    expect(current_path).to eq(new_provider_path)
    attrs = attributes_for(:provider)
    within('form') do
      fill_in 'Name', with: attrs[:name]
      fill_in 'Identifier', with: attrs[:identifier]
      fill_in 'Description', with: attrs[:description]
      click_button 'Create'
    end

    expect(current_path).to eq(providers_path)
    expect(page).to have_css('table tr td', text: attrs[:name])
  end

  scenario 'editing a provider' do
    visit '/providers'
    within('table tr', text: provider.name) do
      click_link 'View'
    end

    click_link 'Edit'

    new_name = "New Name #{provider.name}"

    expect(current_path).to eq(edit_provider_path(provider))

    within('form') do
      fill_in 'Name', with: new_name
      click_button 'Save'
    end

    expect(current_path).to eq(providers_path)
    expect(page).to have_css('table tr td', text: new_name)
  end

  shared_examples 'a validated provider form' do
    scenario 'rejects a blank name' do
      within('form') do
        fill_in 'Name', with: ''
        click_button button
      end

      expect(page).to have_css('.ui.error.message',
                               text: 'Please enter a value for name')
    end

    scenario 'rejects a blank identifier' do
      within('form') do
        fill_in 'Identifier', with: ''
        click_button button
      end

      expect(page).to have_css('.ui.error.message',
                               text: 'Please enter a value for identifier')
    end

    scenario 'rejects a long identifier' do
      within('form') do
        fill_in 'Identifier', with: ('x' * 41)
        click_button button
      end

      expect(page).to have_css('.ui.error.message',
                               text: 'enter a shorter value for identifier')
    end

    scenario 'rejects an invalid identifier' do
      within('form') do
        fill_in 'Identifier', with: 'x='
        click_button button
      end

      expect(page).to have_css('.ui.error.message',
                               text: 'Valid characters for an identifier are')
    end

    scenario 'rejects a blank description' do
      within('form') do
        fill_in 'Description', with: ''
        click_button button
      end

      expect(page).to have_css('.ui.error.message',
                               text: 'Please enter a value for description')
    end
  end

  feature 'validations during edit' do
    background do
      visit '/providers'

      within('table tr', text: provider.name) do
        click_link 'View'
      end

      click_link 'Edit'
    end

    given(:button) { 'Save' }
    it_behaves_like 'a validated provider form'
  end

  feature 'validations during creation' do
    background do
      visit '/providers'
      click_link 'New Provider'

      within('form') do
        fill_in 'Name', with: 'A Valid Name'
        fill_in 'Description', with: 'A Valid Description'
        fill_in 'Identifier', with: 'a-valid-identifier'
      end
    end

    given(:button) { 'Create' }
    it_behaves_like 'a validated provider form'
  end

  scenario 'deleting a provider' do
    visit '/providers'
    expect(page).to have_css('table tr td', text: provider.name)

    within('table tr', text: provider.name) do
      click_link 'View'
    end

    click_delete_button

    expect(current_path).to eq(providers_path)
    expect(page).to have_no_css('table tr td', text: provider.name)
  end
end
