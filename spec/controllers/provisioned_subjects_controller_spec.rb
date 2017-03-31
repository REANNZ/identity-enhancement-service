# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProvisionedSubjectsController, type: :controller do
  let(:object) { create(:provisioned_subject) }
  let(:provider) { object.provider }

  let(:user) do
    create(:subject, :authorized, permission: "providers:#{provider.id}:*")
  end

  before { session[:subject_id] = user.try(:id) }

  context 'get :edit' do
    before { get :edit, provider_id: provider.id, id: object.id }
    subject { response }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('provisioned_subjects/edit') }
    it { is_expected.to have_assigned(:provisioned_subject, object) }

    context 'as an unauthenticated user' do
      let(:user) { nil }

      it { is_expected.to redirect_to('/auth/login') }
    end

    context 'as an unprivileged user' do
      let(:user) { create(:subject) }

      it { is_expected.to be_forbidden }
    end
  end

  context 'patch :update' do
    let(:new_expires) { Time.zone.at(1.year.from_now.to_i) }

    def run
      patch :update, provider_id: object.provider_id, id: object.id,
                     provisioned_subject: { expires_at: new_expires.xmlschema }
    end

    it 'updates the expiry time' do
      expect { run }.to change { object.reload.expires_at }.to(new_expires)
    end

    context 'response' do
      before { run }
      subject { response }

      let(:url) do
        [:new, provider, :provided_attribute, subject_id: object.subject_id]
      end

      it { is_expected.to redirect_to(url) }

      context 'as an unauthenticated user' do
        let(:user) { nil }

        it { is_expected.to redirect_to('/auth/login') }
      end

      context 'as an unprivileged user' do
        let(:user) { create(:subject) }

        it { is_expected.to be_forbidden }
      end
    end
  end
end
