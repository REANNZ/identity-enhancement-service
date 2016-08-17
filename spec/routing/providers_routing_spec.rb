# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ProvidersController, type: :routing do
  context 'get /providers' do
    subject { { get: '/providers' } }
    it { is_expected.to route_to('providers#index') }
  end

  context 'get /providers/new' do
    subject { { get: '/providers/new' } }
    it { is_expected.to route_to('providers#new') }
  end

  context 'post /providers' do
    subject { { post: '/providers' } }
    it { is_expected.to route_to('providers#create') }
  end

  context 'get /providers/:id' do
    subject { { get: '/providers/1' } }
    it { is_expected.to route_to('providers#show', id: '1') }
  end

  context 'get /providers/:id/edit' do
    subject { { get: '/providers/1/edit' } }
    it { is_expected.to route_to('providers#edit', id: '1') }
  end

  context 'patch /providers/:id' do
    subject { { patch: '/providers/1' } }
    it { is_expected.to route_to('providers#update', id: '1') }
  end

  context 'delete /providers/:id' do
    subject { { delete: '/providers/1' } }
    it { is_expected.to route_to('providers#destroy', id: '1') }
  end
end
