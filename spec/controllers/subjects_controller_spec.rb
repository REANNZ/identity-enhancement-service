require 'rails_helper'

RSpec.describe SubjectsController, type: :controller do
  let(:user) { create(:subject, :authorized, permission: 'admin:subjects:*') }
  before { session[:subject_id] = user.try(:id) }
  subject { response }

  let(:object) { create(:subject) }

  context 'get :index' do
    let!(:object) { create(:subject) }
    let(:filter) { nil }
    let(:page) { nil }

    before { get :index, filter: filter, page: page }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('subjects/index') }
    it { is_expected.to have_assigned(:objects, include(object)) }

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }
    end

    context 'with no user' do
      let(:user) { nil }
      it { is_expected.to redirect_to('/auth/login') }
    end

    context 'with a filter' do
      let!(:matching_subject) do
        create(:subject, name: 'NOTHING ELSE MATCHES')
      end

      let(:filter) { 'NOTHING*ELSE*MATCHES' }

      it 'only includes the matching subject' do
        expect(assigns[:objects]).to contain_exactly(matching_subject)
      end

      it 'sets the filter' do
        expect(assigns[:filter]).to eq(filter)
      end
    end

    context 'pagination' do
      let!(:enough_subjects_to_make_a_second_page) { create_list(:subject, 21) }

      let!(:first_subject) do
        create(:subject, name: 'aaaaaaaaaaa first subject')
      end

      context 'on the first page' do
        let(:page) { '1' }

        it 'includes the first subject' do
          expect(assigns[:objects]).to include(first_subject)
        end
      end

      context 'on the second page' do
        let(:page) { '2' }

        it 'excludes the first subject' do
          expect(assigns[:objects]).not_to include(first_subject)
        end
      end
    end
  end

  context 'get :show' do
    before { get :show, id: object.id }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('subjects/show') }
    it { is_expected.to have_assigned(:object, object) }

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }
    end
  end

  context 'post :destroy' do
    def run
      delete :destroy, id: object.id
    end

    let!(:object) { create(:subject) }
    subject { -> { run } }

    it { is_expected.to change(Subject, :count).by(-1) }
    it { is_expected.to have_assigned(:object, object) }

    context 'the response' do
      before { run }
      subject { response }
      it { is_expected.to redirect_to(subjects_path) }
    end

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.not_to change(Subject, :count) }

      context 'the response' do
        before { run }
        subject { response }
        it { is_expected.to have_http_status(:forbidden) }
      end
    end
  end

  context 'get :audits' do
    before { get :audits, id: object.id }

    let(:audit) { object.audits.first }
    let(:other) { create(:subject) }
    let(:other_audit) { other.audits.last }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to have_assigned(:audits, include(audit)) }
    it { is_expected.to have_assigned(:object, object) }
    it { is_expected.not_to have_assigned(:audits, include(other_audit)) }
    it { is_expected.to render_template('subjects/audits') }

    context 'as a non-admin' do
      let(:user) { create(:subject) }
      it { is_expected.to have_http_status(:forbidden) }
    end
  end
end
