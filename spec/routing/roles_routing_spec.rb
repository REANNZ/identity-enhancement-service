# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RolesController, type: :routing do
  context 'get /providers/:provider_id/roles' do
    subject { { get: '/providers/1/roles' } }
    it { is_expected.to route_to('roles#index', provider_id: '1') }
  end

  context 'get /providers/:provider_id/roles/new' do
    subject { { get: '/providers/1/roles/new' } }
    it { is_expected.to route_to('roles#new', provider_id: '1') }
  end

  context 'post /providers/:provider_id/roles' do
    subject { { post: '/providers/1/roles' } }
    it { is_expected.to route_to('roles#create', provider_id: '1') }
  end

  context 'get /providers/:provider_id/roles/:id' do
    subject { { get: '/providers/1/roles/2' } }
    it { is_expected.to route_to('roles#show', provider_id: '1', id: '2') }
  end

  context 'get /providers/:provider_id/roles/edit' do
    subject { { get: '/providers/1/roles/2/edit' } }
    it { is_expected.to route_to('roles#edit', provider_id: '1', id: '2') }
  end

  context 'patch /providers/:provider_id/roles/:id' do
    subject { { patch: '/providers/1/roles/2' } }
    it { is_expected.to route_to('roles#update', provider_id: '1', id: '2') }
  end

  context 'delete /providers/:provider_id/roles/:id' do
    subject { { delete: '/providers/1/roles/2' } }
    it { is_expected.to route_to('roles#destroy', provider_id: '1', id: '2') }
  end
end
