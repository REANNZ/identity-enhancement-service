# frozen_string_literal: true

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
  let(:filter) { nil }
  let(:page) { nil }

  let(:base_params) do
    { provider_id: provider.id, role_id: role.id, filter: filter, page: page }
  end

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

      context 'with a filter' do
        let!(:matching_subject) do
          create(:subject, name: 'NOTHING ELSE MATCHES')
        end

        let(:filter) { 'NOTHING*ELSE*MATCHES' }

        it 'only includes the matching subject' do
          expect(assigns[:subjects]).to contain_exactly(matching_subject)
        end

        it 'sets the filter' do
          expect(assigns[:filter]).to eq(filter)
        end
      end

      context 'pagination' do
        let!(:enough_subjects_to_make_a_second_page) do
          create_list(:subject, 21)
        end

        let!(:first_subject) do
          create(:subject, name: 'aaaaaaaaaaa first subject')
        end

        context 'on the first page' do
          let(:page) { '1' }

          it 'includes the first subject' do
            expect(assigns[:subjects]).to include(first_subject)
          end
        end

        context 'on the second page' do
          let(:page) { '2' }

          it 'excludes the first subject' do
            expect(assigns[:subjects]).not_to include(first_subject)
          end
        end
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

      subject { -> { run } }

      context 'as an administrator' do
        let!(:assoc) { create(:subject_role_assignment, role: role) }
        it { is_expected.to have_assigned(:provider, provider) }
        it { is_expected.to have_assigned(:role, role) }
        it { is_expected.to have_assigned(:assoc, assoc) }
        it { is_expected.to change(model_class, :count).by(-1) }

        context 'the response' do
          before { run }
          subject { response }

          it { is_expected.to redirect_to(provider_role_path(provider, role)) }
        end
      end

      context 'as a non-administrator' do
        let!(:assoc) { create(:subject_role_assignment, role: role) }
        let(:user) { create(:subject) }
        it { is_expected.not_to change(model_class, :count) }

        context 'the response' do
          before { run }
          subject { response }
          it { is_expected.to have_http_status(:forbidden) }
        end
      end

      context 'as an administrator removing their own role membership' do
        let!(:assoc) do
          create(:subject_role_assignment, role: role, subject: user)
        end
        it { is_expected.not_to change(model_class, :count) }

        context 'the response' do
          before { run }
          subject { response }
          it { is_expected.to redirect_to(provider_role_path(provider, role)) }

          it 'has a flash error message' do
            expect(flash[:error])
              .to eq('Administrators cannot revoke their own membership')
          end
        end
      end
    end
  end
end
