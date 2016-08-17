# frozen_string_literal: true
require 'rails_helper'

RSpec.describe InvitationsController, type: :routing do
  let(:identifier) { SecureRandom.urlsafe_base64(19) }

  def action(name, opts = {})
    opts.merge(controller: 'invitations', action: name)
  end

  def provider_action(name, opts = {})
    action(name, opts.merge(provider_id: '1'))
  end

  context 'get /admin/invitations' do
    subject { { get: '/admin/invitations' } }
    it { is_expected.to route_to(action('index')) }
  end

  context 'get /providers/:id/invitations' do
    subject { { get: '/providers/1/invitations' } }
    it { is_expected.not_to be_routable }
  end

  context 'get /providers/:id/invitations/new' do
    subject { { get: '/providers/1/invitations/new' } }
    it { is_expected.to route_to(provider_action('new')) }
  end

  context 'get /providers/:id/invitations/:id/redeliver' do
    subject { { get: '/providers/1/invitations/2/redeliver' } }
    it { is_expected.to route_to(provider_action('redeliver', id: '2')) }
  end

  context 'post /providers/:id/invitations' do
    subject { { post: '/providers/1/invitations' } }
    it { is_expected.to route_to(provider_action('create')) }
  end

  context 'get /invitations/complete' do
    subject { { get: '/invitations/complete' } }
    it { is_expected.to route_to('invitations#complete') }
  end

  context 'get /invitations/:identifier' do
    subject { { get: "/invitations/#{identifier}" } }
    it { is_expected.to route_to(action('show', identifier: identifier)) }
  end

  context 'post /invitations/:identifier' do
    subject { { post: "/invitations/#{identifier}" } }
    it { is_expected.to route_to(action('accept', identifier: identifier)) }
  end
end
