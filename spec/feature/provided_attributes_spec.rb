# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Providing attributes to subjects', js: true do
  given(:user) { create(:subject, :authorized) }

  given!(:attribute) { create(:provided_attribute, subject: object) }
  given(:provider) { attribute.permitted_attribute.provider }
  given!(:other_provider) { create(:provider) }
  given!(:permitted) { create(:permitted_attribute, provider: provider) }
  given(:object) { create(:subject) }
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

    click_link('Identities')
    expect(current_path).to eq("#{base_path}/provided_attributes")
  end

  scenario 'listing the provided attributes' do
    within('#provided-attributes tr', text: object.name) do
      expect(page).to have_content(object.mail)
      expect(page).to have_content(attribute.name)
      expect(page).to have_content(attribute.value)
    end
  end

  scenario 'listing attributes provided by a different provider' do
    visit '/providers'
    within('tr', text: other_provider.name) do
      click_link('View')
    end

    click_link('Identities')

    expect(page).to have_no_css('#provided-attributes tr',
                                text: attribute.value)
  end

  scenario 'providing a new attribute' do
    click_link('Enhance an Identity')

    within('#available-subjects tr', text: object.name) do
      click_link('Enhance Identity')
    end

    expect(current_path).to eq("#{base_path}/provided_attributes/new")
    expect(page).to have_css('table.definition td', text: object.name)
    expect(page).to have_css('table.definition td', text: object.mail)

    message = 'Attributes provided to this Subject will be removed on'
    expect(page).not_to have_css('.ui.message', text: message)

    value = permitted.available_attribute.value

    within('tr', text: value) do
      click_button('Add as Public Attribute')
    end

    expect(current_path).to eq("#{base_path}/provided_attributes/new")
    expect(page).to have_css('#provided-attributes tr', text: value)
  end

  context 'when the subject is pending' do
    let(:invitation) { create(:invitation) }
    let(:object) { invitation.subject }

    scenario 'providing a new attribute' do
      click_link('Enhance an Identity')

      within('#available-subjects tr', text: object.name) do
        click_link('Enhance Identity')
      end

      expect(current_path).to eq("#{base_path}/provided_attributes/new")
      expect(page).to have_css('table.definition td', text: object.name)
      expect(page).to have_css('table.definition td', text: object.mail)

      message = 'Attributes provided to this Subject will be removed on'
      expect(page).to have_css('.ui.message', text: message)

      value = permitted.available_attribute.value

      within('tr', text: value) do
        click_button('Add as Public Attribute')
      end

      expect(current_path).to eq("#{base_path}/provided_attributes/new")
      expect(page).to have_css('#provided-attributes tr', text: value)
    end

    context 'when the invitation has expired' do
      let!(:invitation) { create(:invitation, expires: 1.second.from_now) }

      around { |spec| Timecop.travel(1.day) { spec.run } }

      scenario 'providing a new attribute' do
        click_link('Enhance an Identity')

        within('#available-subjects tr', text: object.name) do
          click_link('Enhance Identity')
        end

        expect(current_path).to eq("#{base_path}/provided_attributes/new")
        expect(page).to have_css('table.definition td', text: object.name)
        expect(page).to have_css('table.definition td', text: object.mail)

        message = 'invitation has expired, and this Subject is pending removal'
        expect(page).to have_css('.ui.message', text: message)

        expect(page)
          .not_to have_css('tr', text: permitted.available_attribute.value)
      end
    end
  end

  scenario 'revoking an attribute' do
    value = attribute.value

    expect(page).to have_css('#provided-attributes tr', text: value, count: 1)
    within('#provided-attributes tr', text: value) do
      click_delete_button
    end

    expect(page).to have_no_css('#provided-attributes tr', text: value)
  end

  scenario 'setting the expiry date of a relationship' do
    within('#provided-attributes tr', text: attribute.value) do
      click_link('View')
    end

    within('tr', text: "Relationship with #{provider.name} Expires") do
      click_link('Edit')
    end

    within('form') do
      date = 1.year.from_now.xmlschema

      execute_script(
        "$('#provisioned_subject_expires_at').pickadate('picker')" \
        ".set('select', '#{date}', { format: 'yyyy-mm-dd' })"
      )

      click_button('Save')
    end

    expect(page).to have_content('in 12 months')
  end
end
