require 'rails_helper'

RSpec.describe SubjectRoleAssignmentsController, type: :controller do
  let(:user) do
    create(:subject, :authorized,
           permission: "providers:#{provider.id}:roles:*")
  end

  before { session[:subject_id] = user.try(:id) }
  subject { response }

  let(:object) { create(:subject) }
  let(:role) { create(:role) }
  let(:provider) { role.provider }
  let(:base_params) { { provider_id: provider.id, role_id: role.id } }
  let(:model_class) { SubjectRoleAssignment }

  context 'by role_id' do
    context 'get :new' do
      before { get :new, base_params }

      it { is_expected.to have_assigned(:provider, provider) }
      it { is_expected.to have_assigned(:role, role) }
      it { is_expected.to have_http_status(:ok) }
      it { is_expected.to render_template('subject_role_assignments/new') }

      context 'as a non-admin' do
        let(:user) { create(:subject) }
        it { is_expected.to have_http_status(:forbidden) }
      end

      context 'as a non-authenticated user' do
        let(:user) { nil }
        it { is_expected.to redirect_to('/auth/login') }
      end
    end

    context 'post :create' do
      def run
        post(:create, base_params.merge(subject_role_assignment: attrs))
      end

      let(:attrs) { { subject_id: object.id } }

      subject { -> { run } }

      it { is_expected.to have_assigned(:provider, provider) }
      it { is_expected.to have_assigned(:role, role) }
      it { is_expected.to have_assigned(:assoc, an_instance_of(model_class)) }
      it { is_expected.to change(model_class, :count).by(1) }

      context 'the response' do
        before { run }
        subject { response }

        it { is_expected.to redirect_to(provider_role_path(provider, role)) }
      end

      context 'as a non-admin' do
        let(:user) { create(:subject) }
        it { is_expected.not_to change(model_class, :count) }

        context 'the response' do
          before { run }
          subject { response }
          it { is_expected.to have_http_status(:forbidden) }
        end
      end
    end

    context 'delete :destroy' do
      def run
        delete :destroy, base_params.merge(id: assoc.id)
      end

      let!(:assoc) { create(:subject_role_assignment, role: role) }
      subject { -> { run } }
      it { is_expected.to have_assigned(:provider, provider) }
      it { is_expected.to have_assigned(:role, role) }
      it { is_expected.to have_assigned(:assoc, assoc) }
      it { is_expected.to change(model_class, :count).by(-1) }

      context 'the response' do
        before { run }
        subject { response }

        it { is_expected.to redirect_to(provider_role_path(provider, role)) }
      end

      context 'as a non-admin' do
        let(:user) { create(:subject) }
        it { is_expected.not_to change(model_class, :count) }

        context 'the response' do
          before { run }
          subject { response }
          it { is_expected.to have_http_status(:forbidden) }
        end
      end
    end
  end
end
