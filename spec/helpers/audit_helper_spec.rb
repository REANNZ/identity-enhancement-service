# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuditHelper, type: :helper do
  let(:user) { create(:subject) }

  class Content
    def initialize(content)
      @html = Nokogiri::HTML.parse(content)
    end

    def has_css?(selector, text: nil)
      if text
        @html.css(selector).any? { |n| n.text.include?(text.to_s) }
      else
        @html.css(selector).present?
      end
    end
  end

  around { |example| Audited.audit_class.as_user(user) { example.run } }
  subject { Content.new(content) }

  context '#audit_table' do
    let(:attribute) { create(:available_attribute) }
    let(:audits) { attribute.audits.all }
    let(:content) { audit_table(audits) }

    around { |example| Timecop.freeze { example.run } }

    it { is_expected.to have_css('th', text: 'Record') }
    it { is_expected.to have_css('th', text: 'Subject') }
    it { is_expected.to have_css('th', text: 'Action') }
    it { is_expected.to have_css('th', text: 'Changes') }

    it { is_expected.to have_css('td', text: attribute.id) }
    it { is_expected.to have_css('td', text: audits.last.comment) }
    it { is_expected.to have_css('td', text: user.name) }
    it { is_expected.to have_css('td time', text: 'less than a minute') }

    context 'for a deletion event' do
      before do
        attribute.audit_comment = 'Destroyed for test'
        attribute.destroy!
      end

      let(:name) { attribute.name }
      let(:value) { attribute.value }
      let(:d) { attribute.description }

      it { is_expected.to have_css('td.negative', text: "Name: #{name}") }
      it { is_expected.to have_css('td.negative', text: "Value: #{value}") }
      it { is_expected.to have_css('td.negative', text: "Description: #{d}") }
    end

    context 'for a creation event' do
      let(:name) { attribute.name }
      let(:value) { attribute.value }
      let(:d) { attribute.description }

      it { is_expected.to have_css('td.positive', text: "Name: #{name}") }
      it { is_expected.to have_css('td.positive', text: "Value: #{value}") }
      it { is_expected.to have_css('td.positive', text: "Description: #{d}") }
    end

    context 'for an update event' do
      let!(:old) { attribute.value }
      let(:new) { attributes_for(:available_attribute)[:value] }

      before do
        attribute.update_attributes!(value: new,
                                     audit_comment: 'Update for test')
      end

      it { is_expected.to have_css('td', text: "Old Value: #{old}") }
      it { is_expected.to have_css('td', text: "New Value: #{new}") }
    end

    context 'for an audit record with no subject' do
      before do
        user.audit_comment = 'Destroying for test case'
        user.destroy!
      end
      it { is_expected.to have_css('td i.icon.warning.sign') }
      it { is_expected.to have_css('td', text: 'No subject was recorded') }
    end
  end
end
