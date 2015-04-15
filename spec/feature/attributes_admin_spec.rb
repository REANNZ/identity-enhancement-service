require 'rails_helper'

RSpec.feature 'Modifying Available Attributes', js: true do
  def create_attribute
    Audited.audit_class.as_user(user) do
      AvailableAttribute.create_with(attrs.slice(:audit_comment))
        .find_or_create_by(attrs.except(:audit_comment))
    end
  end

  given(:user) { create(:subject, :authorized) }
  given(:attrs) { attributes_for(:available_attribute) }
  given!(:attribute) { create_attribute }

  background do
    attrs = create(:aaf_attributes, :from_subject, subject: user)
    RapidRack::TestAuthenticator.jwt = create(:jwt, aaf_attributes: attrs)

    visit '/auth/login'
    click_button 'Login'
  end

  scenario 'viewing the available_attributes list' do
    visit '/admin/available_attributes'
    expect(current_path).to eq('/admin/available_attributes')

    expect(page).to have_css('table tr td', text: attribute.name)
  end

  scenario 'viewing an available_attribute' do
    visit '/admin/available_attributes'
    within('table tr', text: attribute.name) do
      click_link 'View'
    end

    expect(page).to have_content(attribute.name)
    expect(page).to have_content(attribute.value)
  end

  scenario 'creating an available_attribute' do
    visit '/admin/available_attributes'
    click_link 'New Available Attribute'

    expect(current_path).to eq(new_available_attribute_path)
    attrs = attributes_for(:available_attribute)
    within('form') do
      fill_in 'Name', with: attrs[:name]
      fill_in 'Value', with: attrs[:value]
      fill_in 'Description', with: attrs[:description]
      click_button 'Create'
    end

    expect(current_path).to eq(available_attributes_path)
    expect(page).to have_css('table tr td', text: attrs[:name])
  end

  scenario 'editing an available_attribute' do
    visit '/admin/available_attributes'
    within('table tr', text: attribute.name) do
      click_link 'Edit'
    end

    all = %w(urn:mace:aaf.edu.au:ide:researcher:1
             urn:mace:aaf.edu.au:ide:researcher:2)
    new_value = all.find { |v| v != attribute.value }

    expect(current_path).to eq(edit_available_attribute_path(attribute))

    within('form') do
      fill_in 'Value', with: new_value
      click_button 'Save'
    end

    expect(current_path).to eq(available_attributes_path)
    expect(page).to have_css('table tr td', text: new_value)
  end

  shared_examples 'a validated available_attribute form' do
    scenario 'rejects a blank name' do
      within('form') do
        fill_in 'Name', with: ''
        click_button button
      end

      expect(page).to have_css('.ui.error.message',
                               text: 'Please enter a value for name')
    end

    scenario 'rejects an invalid name' do
      within('form') do
        fill_in 'Name', with: 'auEduPersonSharedToken'
        click_button button
      end

      expect(page).to have_css('.ui.error.message',
                               text: 'Name must be eduPersonEntitlement')
    end

    scenario 'rejects a blank value' do
      within('form') do
        fill_in 'Value', with: ''
        click_button button
      end

      expect(page).to have_css('.ui.error.message',
                               text: 'Please enter a value for value')
    end

    scenario 'rejects an invalid value' do
      within('form') do
        fill_in 'Value', with: 'a:b:c:d:e:f'
        click_button button
      end

      expect(page).to have_css('.ui.error.message',
                               text: 'Value must conform to documented style')
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
      visit '/admin/available_attributes'

      within('table tr', text: attribute.name) do
        click_link 'Edit'
      end

      fill_in 'Value', with: 'urn:mace:aaf.edu.au:ide:valid:attribute'
    end

    given(:button) { 'Save' }
    it_behaves_like 'a validated available_attribute form'
  end

  feature 'validations during creation' do
    background do
      visit '/admin/available_attributes'
      click_link 'New Available Attribute'

      within('form') do
        fill_in 'Name', with: 'A Valid Name'
        fill_in 'Description', with: 'A Valid Description'
        fill_in 'Value', with: 'urn:mace:aaf.edu.au:ide:valid:attribute'
      end
    end

    given(:button) { 'Create' }
    it_behaves_like 'a validated available_attribute form'
  end

  scenario 'deleting an available_attribute which is in use' do
    create(:permitted_attribute, available_attribute: attribute)

    visit '/admin/available_attributes'
    expect(page).to have_css('tr td', text: attribute.value)

    within('table tr', text: attribute.name) do
      click_delete_button
    end

    expect(current_path).to eq(available_attributes_path)
    expect(page).to have_css('.ui.message', text: 'Unable to delete')
  end

  scenario 'deleting an available_attribute' do
    attribute.permitted_attributes.destroy_all

    visit '/admin/available_attributes'
    expect(page).to have_css('tr td', text: attribute.value)

    within('table tr', text: attribute.name) do
      click_delete_button
    end

    expect(current_path).to eq(available_attributes_path)
    expect(page).to have_no_css('tr td', text: attribute.value)
  end

  scenario 'viewing the audit log' do
    visit '/admin/available_attributes'

    click_link 'Audit'

    audit = attribute.audits.last

    expect(current_path).to eq(audit_available_attributes_path)
    expect(page).to have_css('table tr td', text: audit.user.name)
    expect(page).to have_css('table tr td', text: audit.comment)
  end
end
