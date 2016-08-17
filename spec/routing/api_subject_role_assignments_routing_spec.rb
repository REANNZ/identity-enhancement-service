# frozen_string_literal: true
require 'rails_helper'

RSpec.describe APISubjectRoleAssignmentsController, type: :routing do
  let(:base) { { provider_id: '1', role_id: '2' } }

  def action(name)
    "api_subject_role_assignments##{name}"
  end

  context 'get /providers/:id/roles/:id/api_members' do
    subject { { get: '/providers/1/roles/2/api_members' } }
    it { is_expected.not_to be_routable }
  end

  context 'get /providers/:id/roles/:id/api_members/new' do
    subject { { get: '/providers/1/roles/2/api_members/new' } }
    it { is_expected.to route_to(action('new'), base) }
  end

  context 'post /providers/:id/roles/:id/api_members' do
    subject { { post: '/providers/1/roles/2/api_members' } }
    it { is_expected.to route_to(action('create'), base) }
  end

  context 'get /providers/:id/roles/:id/api_members/:id' do
    subject { { get: '/providers/1/roles/2/api_members/3' } }
    it { is_expected.not_to be_routable }
  end

  context 'patch /providers/:id/roles/:id/api_members/:id' do
    subject { { patch: '/providers/1/roles/2/api_members/3' } }
    it { is_expected.not_to be_routable }
  end

  context 'delete /providers/:id/roles/:id/api_members/:id' do
    subject { { delete: '/providers/1/roles/2/api_members/3' } }
    it { is_expected.to route_to(action('destroy'), base.merge(id: '3')) }
  end
end
