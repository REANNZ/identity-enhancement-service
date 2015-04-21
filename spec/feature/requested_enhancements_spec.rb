require 'rails_helper'

RSpec.feature 'Requested Enhancements', js: true do
  let!(:provider) { create(:provider) }

  background do
    attrs = create(:aaf_attributes, :from_subject, subject: user)
    RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)

    visit '/auth/login'
    click_button 'Login'

    expect(current_path).to eq('/dashboard')
  end

  context 'as a regular user' do
    let(:user) { create(:subject) }
    let(:attrs) { attributes_for(:requested_enhancement) }

    it 'requests the enhancement' do
      click_link('Request Enhancement')

      within('.search form') do
        fill_in(:filter, with: provider.name)
        click_button('Search')
      end

      within('tr', text: provider.name) do
        click_link('Select')
      end

      within('form') do
        fill_in 'Message', with: attrs[:message]
        click_button('Submit Request')
      end

      expect(page).to have_css('.success.message',
                               text: 'Your request for identity enhancement ' \
                                     "has been sent to #{provider.name}")
      expect(current_path).to eq('/dashboard')
    end
  end

  context 'as a provider admin' do
    let(:user) do
      create(:subject, :authorized,
             permission: "providers:#{provider.id}:*").tap do |user|
        user.roles.first.update_attributes!(provider: provider,
                                            audit_comment: 'Test')
      end
    end

    let!(:req) { create(:requested_enhancement, provider: provider) }
    let!(:attr) { create(:permitted_attribute, provider: provider) }

    it 'actions the request' do
      within('tr', text: provider.name) do
        click_link('View')
      end

      click_link('Requests')

      within('tr', text: req.subject.name) do
        click_link('View')
      end

      expect(page).to have_css('.definition td', text: req.subject.name)
        .and have_css('.enhancement-request-message', text: req.message)

      click_link('Enhance Identity')

      within('tr', text: attr.available_attribute.value) do
        click_button('Add')
      end

      expect(page).to have_css('.success.message', text: 'Provided attribute')
        .and have_css('tr', text: attr.available_attribute.value)

      click_link('Dismiss')

      expect(current_path)
        .to eq("/providers/#{provider.id}/requested_enhancements")
      expect(page).not_to have_css('tr', text: req.subject.name)
    end
  end
end
