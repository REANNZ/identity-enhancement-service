# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Viewing Subjects', js: true do
  given(:user) { create(:subject, :authorized, complete: true) }
  given!(:object) do
    Audited.audit_class.as_user(user) { create(:subject, complete: true) }
  end

  background do
    attrs = create(:aaf_attributes, :from_subject, subject: user)
    RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)

    visit '/auth/login'
    click_button 'Login'
  end

  scenario 'viewing the subject list' do
    visit '/admin/subjects'

    expect(current_path).to eq('/admin/subjects')
    expect(page).to have_css('table tr td', text: object.name)
  end

  scenario 'viewing a subject record' do
    visit '/admin/subjects'

    within('table tr', text: object.name) do
      click_link('View')
    end

    expect(current_path).to eq("/admin/subjects/#{object.id}")
    expect(page).to have_content(object.name)
    expect(page).to have_content(object.mail)
    expect(page).to have_content(object.shared_token)
    expect(page).to have_content(object.targeted_id)
    expect(page).to have_css('tr', text: 'Complete Yes')
  end

  scenario 'deleting a subject record' do
    visit '/admin/subjects'

    within('table tr', text: object.name) do
      click_delete_button
    end

    expect(current_path).to eq('/admin/subjects')
    expect(page).to have_no_content(object.mail)
  end

  scenario 'viewing the audit log' do
    visit '/admin/subjects'

    within('table tr', text: object.name) do
      click_link('View')
    end

    click_link('Audit')

    audit = object.audits.last

    expect(current_path).to eq(audit_subject_path(object))
    expect(page).to have_css('table tr td', text: audit.user.name)
    expect(page).to have_css('table tr td', text: audit.comment)
  end
end
