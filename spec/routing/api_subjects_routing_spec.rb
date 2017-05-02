# frozen_string_literal: true

require 'rails_helper'

RSpec.describe APISubjectsController, type: :routing do
  def action(name)
    "api_subjects##{name}"
  end

  context 'get /providers/:id/subjects' do
    subject { { get: '/providers/1/api_subjects' } }
    it { is_expected.to route_to(action('index'), provider_id: '1') }
  end

  context 'get /providers/:id/subjects/:id' do
    subject { { get: '/providers/1/api_subjects/2' } }
    it { is_expected.to route_to(action('show'), provider_id: '1', id: '2') }
  end

  context 'get /providers/:id/subjects/:id/audits' do
    subject { { get: '/providers/1/api_subjects/2/audits' } }
    it { is_expected.to route_to(action('audits'), provider_id: '1', id: '2') }
  end

  context 'get /providers/:id/subjects/new' do
    subject { { get: '/providers/1/api_subjects/new' } }
    it { is_expected.to route_to(action('new'), provider_id: '1') }
  end

  context 'post /providers/:id/subjects' do
    subject { { post: '/providers/1/api_subjects' } }
    it { is_expected.to route_to(action('create'), provider_id: '1') }
  end

  context 'get /providers/:id/subjects/:id/edit' do
    subject { { get: '/providers/1/api_subjects/2/edit' } }
    it { is_expected.to route_to(action('edit'), provider_id: '1', id: '2') }
  end

  context 'patch /providers/:id/subjects/:id' do
    subject { { patch: '/providers/1/api_subjects/2' } }
    it { is_expected.to route_to(action('update'), provider_id: '1', id: '2') }
  end

  context 'delete /providers/:id/subjects/:id' do
    subject { { delete: '/providers/1/api_subjects/2' } }
    it { is_expected.to route_to(action('destroy'), provider_id: '1', id: '2') }
  end
end
