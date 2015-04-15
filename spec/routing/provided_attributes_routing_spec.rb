require 'rails_helper'

RSpec.describe ProvidedAttributesController, type: :routing do
  def action(name)
    "provided_attributes##{name}"
  end

  context 'get /providers/:id/provided_attributes' do
    subject { { get: '/providers/1/provided_attributes' } }
    it { is_expected.to route_to(action('index'), provider_id: '1') }
  end

  context 'get /providers/:id/provided_attributes/select_subject' do
    subject { { get: '/providers/1/provided_attributes/select_subject' } }
    it { is_expected.to route_to(action('select_subject'), provider_id: '1') }
  end

  context 'get /providers/:id/provided_attributes/new' do
    subject { { get: '/providers/1/provided_attributes/new' } }
    it { is_expected.to route_to(action('new'), provider_id: '1') }
  end

  context 'post /providers/:id/provided_attributes' do
    subject { { post: '/providers/1/provided_attributes' } }
    it { is_expected.to route_to(action('create'), provider_id: '1') }
  end

  context 'delete /providers/:id/provided_attributes/:id' do
    subject { { delete: '/providers/1/provided_attributes/2' } }
    it { is_expected.to route_to(action('destroy'), provider_id: '1', id: '2') }
  end
end
