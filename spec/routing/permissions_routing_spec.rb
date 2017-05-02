# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PermissionsController, type: :routing do
  let(:opts) { { provider_id: '1', role_id: '2' } }

  context 'get /providers/:id/roles/:id/permissions' do
    subject { { get: '/providers/1/roles/2/permissions' } }
    it { is_expected.to route_to('permissions#index', opts) }
  end

  context 'post /providers/:id/roles/:id/permissions' do
    subject { { post: '/providers/1/roles/2/permissions' } }
    it { is_expected.to route_to('permissions#create', opts) }
  end

  context 'delete /providers/:id/roles/:id/permissions/:id' do
    subject { { delete: '/providers/1/roles/2/permissions/3' } }
    it { is_expected.to route_to('permissions#destroy', opts.merge(id: '3')) }
  end

  context 'get /providers/:id/roles/:id/permissions/new' do
    subject { { get: '/providers/1/roles/2/permissions/new' } }
    it { is_expected.not_to be_routable }
  end

  context 'get /providers/:id/roles/:id/permissions/:id/edit' do
    subject { { get: '/providers/1/roles/2/permissions/3/edit' } }
    it { is_expected.not_to be_routable }
  end

  context 'patch /providers/:id/roles/:id/permissions/:id' do
    subject { { patch: '/providers/1/roles/2/permissions/3' } }
    it { is_expected.not_to be_routable }
  end
end
