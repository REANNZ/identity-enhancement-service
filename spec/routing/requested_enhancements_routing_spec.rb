# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RequestedEnhancementsController, type: :routing do
  def action(name, args = {})
    args.merge(controller: 'requested_enhancements', action: name)
  end

  context 'get /providers/:id/requested_enhancements' do
    subject { { get: '/providers/1/requested_enhancements' } }
    it { is_expected.to route_to(action('index', provider_id: '1')) }
  end

  context 'get /providers/:id/requested_enhancements/new' do
    subject { { get: '/providers/1/requested_enhancements/new' } }
    it { is_expected.to route_to(action('new', provider_id: '1')) }
  end

  context 'post /providers/:id/requested_enhancements' do
    subject { { post: '/providers/1/requested_enhancements' } }
    it { is_expected.to route_to(action('create', provider_id: '1')) }
  end

  context 'get /providers/:id/requested_enhancements/:id' do
    subject { { get: '/providers/1/requested_enhancements/2' } }
    it { is_expected.to route_to(action('show', provider_id: '1', id: '2')) }
  end

  context 'get /providers/:id/requested_enhancements/:id/edit' do
    subject { { get: '/providers/1/requested_enhancements/2/edit' } }
    it { is_expected.not_to be_routable }
  end

  context 'patch /providers/:id/requested_enhancements/:id' do
    subject { { patch: '/providers/1/requested_enhancements/2' } }
    it { is_expected.not_to be_routable }
  end

  context 'post /providers/:id/requested_enhancements/:id/dismiss' do
    subject { { post: '/providers/1/requested_enhancements/2/dismiss' } }
    it { is_expected.to route_to(action('dismiss', provider_id: '1', id: '2')) }
  end

  context 'delete /providers/:id/requested_enhancements/:id' do
    subject { { delete: '/providers/1/requested_enhancements/2' } }
    it { is_expected.to route_to(action('destroy', provider_id: '1', id: '2')) }
  end

  context 'get /request_enhancement' do
    subject { { get: '/request_enhancement' } }
    it { is_expected.to route_to(action('select_provider')) }
  end
end
