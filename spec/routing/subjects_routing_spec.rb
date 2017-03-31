# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubjectsController, type: :routing do
  context 'get /admin/subjects' do
    subject { { get: '/admin/subjects' } }
    it { is_expected.to route_to('subjects#index') }
  end

  context 'get /admin/subjects/:id' do
    subject { { get: '/admin/subjects/1' } }
    it { is_expected.to route_to('subjects#show', id: '1') }
  end

  context 'get /admin/subjects/:id/audits' do
    subject { { get: '/admin/subjects/1/audits' } }
    it { is_expected.to route_to('subjects#audits', id: '1') }
  end

  context 'get /admin/subjects/new' do
    subject { { get: '/admin/subjects/new' } }
    # Derp.
    it { is_expected.to route_to('subjects#show', id: 'new') }
  end

  context 'post /admin/subjects' do
    subject { { post: '/admin/subjects' } }
    it { is_expected.not_to be_routable }
  end

  context 'get /admin/subjects/:id/edit' do
    subject { { get: '/admin/subjects/1/edit' } }
    it { is_expected.not_to be_routable }
  end

  context 'patch /admin/subjects/:id' do
    subject { { patch: '/admin/subjects/1' } }
    it { is_expected.to route_to('subjects#update', id: '1') }
  end

  context 'delete /admin/subjects/:id' do
    subject { { delete: '/admin/subjects/1' } }
    it { is_expected.to route_to('subjects#destroy', id: '1') }
  end
end
