# frozen_string_literal: true
require 'rails_helper'

RSpec.describe InvitationsController, type: :controller do
  let(:invitation) { create(:invitation) }
  let!(:provider) { invitation.provider }
  subject { response }

  context 'get :index' do
    def run
      get :index
    end

    let!(:invitation) { create(:invitation) }
    let(:permission) { 'admin:invitations:list' }
    it_behaves_like 'a restricted action'

    context 'as a permitted user' do
      let(:user) { create(:subject, :authorized) }
      before do
        session[:subject_id] = user.id
        run
      end

      it 'lists the invitations' do
        expect(assigns[:invitations]).to include(invitation)
      end

      it 'lists the providers' do
        expect(assigns[:providers]).to include(provider)
      end

      it { is_expected.to render_template('invitations/index') }
    end
  end

  context 'get :new' do
    def run
      get :new, provider_id: provider.id
    end

    let(:permission) { "providers:#{provider.id}:invitations:create" }
    it_behaves_like 'a restricted action'

    context 'as a permitted user' do
      let(:user) { create(:subject, :authorized) }
      before do
        session[:subject_id] = user.id
        run
      end

      it { is_expected.to render_template('invitations/new') }

      it 'assigns the invitation' do
        expect(assigns[:invitation]).to be_a_new(Invitation)
      end

      it 'defaults to 4 week expiry' do
        expect(assigns[:invitation].expires).to eq(4.weeks.from_now.to_date)
      end
    end
  end

  context 'post :create' do
    let(:permission) { "providers:#{provider.id}:invitations:create" }
    it_behaves_like 'a restricted action'

    let(:attrs) do
      attributes_for(:subject).slice(:name, :mail)
                              .merge(provider_id: provider.id,
                                     expires: 1.week.from_now.to_date.xmlschema)
    end

    def run
      post :create, provider_id: provider.id, invitation: attrs
    end

    context 'as a permitted user' do
      let(:user) { create(:subject, :authorized) }
      before { session[:subject_id] = user.id }

      it 'creates the subject' do
        expect { run }.to change(Subject, :count).by(1)
      end

      it 'creates the invitation' do
        expect { run }.to change(Invitation, :count).by(1)
      end

      it 'sets the expiry' do
        run
        expect(Invitation.last.expires).to eq(Time.zone.parse(attrs[:expires]))
      end

      it 'sets flash success' do
        run
        expect(flash[:success]).to be_present
      end

      it do
        run
        expect(response)
          .to redirect_to(provider_provided_attributes_path(provider))
      end

      context 'email delivery' do
        before { run }
        let(:text) { 'You have been invited to AAF Identity Enhancement' }
        it { is_expected.to have_sent_email.to(attrs[:mail]) }
        it { is_expected.to have_sent_email.matching_body(/#{text}/) }

        it 'links to the invitation in the message' do
          expected = %r{/invitations/#{Invitation.last.identifier}}
          expect(subject).to have_sent_email.matching_body(expected)
        end
      end

      context 'email failure' do
        before { expect(Mail).to receive(:deliver) { raise('Nope') } }

        it 'does not create a subject' do
          expect { run }.to raise_error(/Nope/).and not_change(Subject, :count)
        end

        it 'does not create a invitation' do
          expect { run }.to raise_error(/Nope/)
            .and not_change(Invitation, :count)
        end
      end

      context 'when subject with provided email already exists' do
        let(:attrs) do
          attributes_for(:subject, mail: user.mail)
            .slice(:name, :mail)
            .merge(provider_id: provider.id)
        end

        it 'does not create a subject' do
          expect { run }.to not_change(Subject, :count)
        end

        it 'does not create a invitation' do
          expect { run }.to not_change(Invitation, :count)
        end

        it 'sets flash error' do
          run
          expect(flash[:error]).to be_present
        end
      end
    end
  end

  context 'get :redeliver' do
    def run
      get :redeliver, provider_id: provider.id, id: invitation.id
    end

    context 'as a permitted user' do
      before do
        invitation.update_attributes!(last_sent_at: 4.weeks.ago,
                                      audit_comment: 'Updated for test')
        session[:subject_id] = user.id
        run
      end

      let(:user) { create(:subject, :authorized) }
      let(:text) { 'You have been invited to AAF Identity Enhancement' }

      it { is_expected.to have_sent_email.to(invitation.mail) }
      it { is_expected.to have_sent_email.matching_body(/#{text}/) }

      it 'updates the last_sent_at timestamp' do
        expect(invitation.reload.last_sent_at.to_i).to eq(Time.zone.now.to_i)
      end

      it 'links to the invitation in the message' do
        expected = %r{/invitations/#{invitation.identifier}}
        expect(subject).to have_sent_email.matching_body(expected)
      end

      it 'gives the provider details in the message' do
        expected = /#{provider.name}/
        expect(subject).to have_sent_email.matching_body(expected)
      end

      it 'gives the contact details of the provider admin who invited' do
        name_pattern = Regexp.new(user.name.tr("'", '.'))
        expect(subject).to have_sent_email.matching_body(name_pattern)
      end

      it 'redirects back to the Identities page' do
        expect(response).to redirect_to([provider, :provided_attributes])
      end

      it 'sets a flash message' do
        expect(flash[:success])
          .to match(/Redelivered invitation to #{invitation.mail}/)
      end
    end
  end

  context 'get :show' do
    def run
      get :show, identifier: invitation.identifier
    end

    context 'for an invalid identifier' do
      it 'raises an error' do
        # Causes a 404 in production
        expect { get :show, identifier: 'nonexistent' }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'for a used invite' do
      let(:invitation) { create(:invitation, used: true) }
      before { run }
      it { is_expected.to render_template('invitations/used') }
      it { is_expected.to have_assigned(:invitation, invitation) }
    end

    context 'for a valid invite' do
      before { run }
      it { is_expected.to render_template('invitations/show') }
      it { is_expected.to have_assigned(:invitation, invitation) }
    end
  end

  context 'post :accept' do
    let(:user) { create(:subject) }

    def run
      post :accept, identifier: invitation.identifier
    end

    context 'for an invalid identifier' do
      it 'raises an error' do
        # Causes a 404 in production
        expect { post :accept, identifier: 'nonexistent' }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    it 'assigns the invite code in the session' do
      expect { run }.to change { session[:invite] }.to(invitation.identifier)
    end

    it do
      run
      expect(response).to redirect_to('/auth/login')
    end
  end
end
