# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Visiting the invitation page', js: true do
  given(:invitation) { create(:invitation) }

  background do
    attrs = create(:aaf_attributes, displayname: invitation.name,
                                    mail: invitation.mail)

    RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)
  end

  scenario 'accepting the invitation' do
    visit "/invitations/#{invitation.identifier}"
    click_button 'Accept'

    expect(current_path).to eq('/auth/login')
    click_button 'Login'

    expect(current_path).to eq('/invitations/complete')
    expect(page).to have_content('You have accepted your invitation')
  end

  context 'with a used invitation' do
    given(:invitation) { create(:invitation, used: true) }

    scenario 'attempting to accept the invitation' do
      visit "/invitations/#{invitation.identifier}"
      expect(page).to have_content('already been accepted')
    end
  end

  context 'with an expired invitation' do
    given!(:invitation) { create(:invitation, expires: 30.seconds.from_now) }

    scenario 'attempting to accept the invitation' do
      Timecop.travel(1.minute) do
        visit "/invitations/#{invitation.identifier}"
        expect(page).to have_content('invitation expired')
      end
    end
  end
end
