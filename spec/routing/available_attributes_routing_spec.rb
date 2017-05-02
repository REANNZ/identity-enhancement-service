# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AvailableAttributesController, type: :routing do
  context 'get /admin/available_attributes' do
    subject { { get: '/admin/available_attributes' } }
    it { is_expected.to route_to('available_attributes#index') }
  end

  context 'get /admin/available_attributes/new' do
    subject { { get: '/admin/available_attributes/new' } }
    it { is_expected.to route_to('available_attributes#new') }
  end

  context 'post /admin/available_attributes' do
    subject { { post: '/admin/available_attributes' } }
    it { is_expected.to route_to('available_attributes#create') }
  end

  context 'get /admin/available_attributes/:id' do
    subject { { get: '/admin/available_attributes/1' } }
    it { is_expected.to route_to('available_attributes#show', id: '1') }
  end

  context 'get /admin/available_attributes/:id/edit' do
    subject { { get: '/admin/available_attributes/1/edit' } }
    it { is_expected.to route_to('available_attributes#edit', id: '1') }
  end

  context 'patch /admin/available_attributes/:id' do
    subject { { patch: '/admin/available_attributes/1' } }
    it { is_expected.to route_to('available_attributes#update', id: '1') }
  end

  context 'delete /admin/available_attributes/:id' do
    subject { { delete: '/admin/available_attributes/1' } }
    it { is_expected.to route_to('available_attributes#destroy', id: '1') }
  end

  context 'get /admin/available_attributes/audits' do
    subject { { get: '/admin/available_attributes/audits' } }
    it { is_expected.to route_to('available_attributes#audits') }
  end

  context 'get /admin/available_attributes/:id/audits' do
    subject { { get: '/admin/available_attributes/1/audits' } }
    it { is_expected.to route_to('available_attributes#audits', id: '1') }
  end
end
