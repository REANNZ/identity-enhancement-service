require 'rails_helper'

RSpec.feature 'Inviting a new subject', js: true do
  given(:user) { create(:subject, :authorized) }
  given!(:provider) { create(:provider) }
  given(:attrs) { attributes_for(:subject) }

  background do
    attrs = create(:aaf_attributes, :from_subject, subject: user)
    RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)

    visit '/auth/login'
    click_button 'Login'

    visit '/providers'
    within('tr', text: provider.name) do
      click_link('View')
    end

    click_link('Identities')
  end

  scenario 'creating an invitation' do
    click_link('Enhance an Identity')
    click_link('Invite a User')
    expect(current_path).to eq("/providers/#{provider.id}/invitations/new")

    within('form') do
      fill_in 'Name', with: attrs[:name]
      fill_in 'Email Address', with: attrs[:mail]
      click_button('Send Invitation')
    end

    expect(current_path).to eq("/providers/#{provider.id}/provided_attributes")
    expect(page).to have_sent_email.to(attrs[:mail])
      .with_subject('Invitation to AAF Identity Enhancement')

    click_link('Enhance an Identity')
    within('#available-subjects tr', text: attrs[:name]) do
      expect(page).to have_css('td', text: 'Pending')
    end
  end
end
