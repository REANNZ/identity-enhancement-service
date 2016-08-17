# frozen_string_literal: true
require 'rails_helper'

RSpec.describe DashboardController, type: :controller do
  let(:user) { create(:subject, :authorized) }
  let(:role) { user.roles.first }
  let(:attribute) { create(:provided_attribute, subject: user) }

  before { session[:subject_id] = user.id }

  context 'get :index' do
    before { get :index }
    subject { response }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('dashboard/index') }
    it { is_expected.to have_assigned(:subject, user) }

    it 'builds a provider map' do
      expect(assigns[:provider_roles]).to include(role.provider => [role])
    end

    it 'sets the provided attributes' do
      expect(assigns[:provided_attributes]).to include(attribute)
    end

    context 'with api only roles' do
      let(:api_role) do
        create(:role, provider: role.provider).tap do |role|
          create(:permission, value: 'api:attributes:read', role: role)
          create(:subject_role_assignment, role: role, subject: user)
        end
      end

      it 'is assigned the api_role' do
        expect(user.roles).to include(api_role)
      end

      it 'builds a filtered provider map' do
        expect(assigns[:provider_roles])
          .not_to include(api_role.provider => [api_role])
      end
    end
  end
end
