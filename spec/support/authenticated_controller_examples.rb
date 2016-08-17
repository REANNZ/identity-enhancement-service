# frozen_string_literal: true
RSpec.shared_examples 'a restricted action' do
  subject { response }

  before do
    session[:subject_id] = subject_id
    run
  end

  context 'with no session' do
    let(:subject_id) { nil }

    it { is_expected.to redirect_to('/auth/login') }
  end

  context 'with an unprivileged session' do
    let(:user) { create(:subject) }
    let(:subject_id) { user.id }

    it { is_expected.to be_forbidden }
    it { is_expected.to render_template('errors/forbidden') }
  end

  context 'with a privileged session' do
    let(:user) { create(:subject, :authorized, permission: permission) }
    let(:subject_id) { user.id }

    it { is_expected.not_to be_forbidden }
  end
end

RSpec.shared_examples 'an unrestricted action' do
  subject { response }

  before do
    session[:subject_id] = subject_id
    run
  end

  context 'with no session' do
    let(:subject_id) { nil }

    it { is_expected.to redirect_to('/auth/login') }
  end

  context 'with an unprivileged session' do
    let(:user) { create(:subject) }
    let(:subject_id) { user.id }

    it { is_expected.not_to be_forbidden }
  end
end

RSpec.shared_examples 'an unauthenticated action' do
  subject { response }

  before do
    session[:subject_id] = subject_id
    run
  end

  context 'with no session' do
    let(:subject_id) { nil }

    it { is_expected.not_to redirect_to('/auth/login') }
  end

  context 'with a session' do
    let(:user) { create(:subject) }
    let(:subject_id) { user.id }

    it { is_expected.not_to redirect_to('/auth/login') }
  end
end
