require 'rails_helper'

RSpec.describe APISubjectRoleAssignmentsController, type: :controller do
  let(:user) do
    create(:subject, :authorized,
           permission: "providers:#{provider.id}:roles:*")
  end

  before { session[:subject_id] = user.try(:id) }
  subject { response }

  let(:api_subject) { create(:api_subject) }
  let(:role) { create(:role) }
  let(:provider) { role.provider }
  let(:filter) { nil }
  let(:page) { nil }

  let(:base_params) do
    { provider_id: provider.id, role_id: role.id, page: page, filter: filter }
  end

  let(:model_class) { APISubjectRoleAssignment }

  context 'by role_id' do
    context 'get :new' do
      before { get :new, base_params }

      it { is_expected.to have_assigned(:provider, provider) }
      it { is_expected.to have_assigned(:role, role) }
      it { is_expected.to have_http_status(:ok) }
      it { is_expected.to render_template('api_subject_role_assignments/new') }

      context 'as a non-admin' do
        let(:user) { create(:subject) }
        it { is_expected.to have_http_status(:forbidden) }
      end

      context 'as a non-authenticated user' do
        let(:user) { nil }
        it { is_expected.to redirect_to('/auth/login') }
      end

      context 'with a filter' do
        let!(:matching_api_subject) do
          create(:api_subject, description: 'NOTHING ELSE MATCHES')
        end

        let!(:other_api_subject) { create(:api_subject) }

        let(:filter) { 'NOTHING*ELSE*MATCHES' }

        it 'only includes the matching api_subject' do
          expect(assigns[:api_subjects])
            .to contain_exactly(matching_api_subject)
        end

        it 'sets the filter' do
          expect(assigns[:filter]).to eq(filter)
        end
      end

      context 'pagination' do
        let!(:enough_api_subjects_to_make_a_second_page) do
          create_list(:api_subject, 21)
        end

        let!(:first_api_subject) do
          create(:api_subject, x509_cn: 'aaaaaaaaaaa_first_api_subject')
        end

        context 'on the first page' do
          let(:page) { '1' }

          it 'includes the first api_subject' do
            expect(assigns[:api_subjects]).to include(first_api_subject)
          end
        end

        context 'on the second page' do
          let(:page) { '2' }

          it 'excludes the first api_subject' do
            expect(assigns[:api_subjects]).not_to include(first_api_subject)
          end
        end
      end
    end

    context 'post :create' do
      def run
        post(:create, base_params.merge(api_subject_role_assignment: attrs))
      end

      let(:attrs) { { api_subject_id: api_subject.id } }

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

      let!(:assoc) { create(:api_subject_role_assignment, role: role) }
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
