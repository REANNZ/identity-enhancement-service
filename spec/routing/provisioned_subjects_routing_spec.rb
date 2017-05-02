# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProvisionedSubjectsController, type: :routing do
  def action(name, opts)
    opts.merge(controller: 'provisioned_subjects', action: name,
               provider_id: '1')
  end

  context 'get /providers/:id/provisioned_subjects/:id/edit' do
    subject { { get: '/providers/1/provisioned_subjects/2/edit' } }
    it { is_expected.to route_to(action('edit', id: '2')) }
  end

  context 'patch /providers/:id/provisioned_subjects/:id' do
    subject { { patch: '/providers/1/provisioned_subjects/2' } }
    it { is_expected.to route_to(action('update', id: '2')) }
  end
end
