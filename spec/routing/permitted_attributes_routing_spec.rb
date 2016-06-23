# frozen_string_literal: true
require 'rails_helper'

RSpec.describe PermittedAttributesController, type: :routing do
  def action(name)
    "permitted_attributes##{name}"
  end

  context 'get /admin/providers/:id/permitted_attributes' do
    subject { { get: '/admin/providers/1/permitted_attributes' } }
    it { is_expected.to route_to(action('index'), provider_id: '1') }
  end

  context 'post /admin/providers/:id/permitted_attributes' do
    subject { { post: '/admin/providers/1/permitted_attributes' } }
    it { is_expected.to route_to(action('create'), provider_id: '1') }
  end

  context 'delete /admin/providers/:id/permitted_attributes/:id' do
    subject { { delete: '/admin/providers/1/permitted_attributes/2' } }
    it { is_expected.to route_to(action('destroy'), provider_id: '1', id: '2') }
  end

  context 'get /admin/providers/:id/permitted_attributes/new' do
    subject { { get: '/admin/providers/1/permitted_attributes/new' } }
    it { is_expected.not_to be_routable }
  end

  context 'get /admin/providers/:id/permitted_attributes/:id' do
    subject { { get: '/admin/providers/1/permitted_attributes/2' } }
    it { is_expected.not_to be_routable }
  end

  context 'patch /admin/providers/:id/permitted_attributes/:id' do
    subject { { patch: '/admin/providers/1/permitted_attributes/2' } }
    it { is_expected.not_to be_routable }
  end

  context 'get /admin/providers/:id/permitted_attributes/:id/edit' do
    subject { { get: '/admin/providers/1/permitted_attributes/2/edit' } }
    it { is_expected.not_to be_routable }
  end
end
