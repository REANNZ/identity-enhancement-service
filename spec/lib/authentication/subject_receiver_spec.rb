require 'rails_helper'

module Authentication
  RSpec.describe SubjectReceiver do
    let(:env) { {} }

    context '#map_attributes' do
      let(:attrs) do
        keys = %w(edupersontargetedid auedupersonsharedtoken displayname mail)
        keys.reduce({}) { |a, e| a.merge(e => e) }
      end

      it 'maps the attributes' do
        expect(subject.map_attributes(env, attrs))
          .to eq(name: 'displayname',
                 mail: 'mail',
                 shared_token: 'auedupersonsharedtoken',
                 targeted_id: 'edupersontargetedid')
      end
    end

    context '#finish' do
      context 'with an invitation code' do
        let!(:invitation) { create(:invitation) }
        let(:env) { { 'rack.session' => { invite: invitation.identifier } } }

        it 'redirects to the invitation complete page' do
          response = [302, { 'Location' => '/invitations/complete' }, []]
          expect(subject.finish(env)).to eq(response)
        end

        it 'clears the invite code' do
          expect { subject.finish(env) }
            .to change { env['rack.session'] }.to be_empty
        end
      end

      it 'redirects to the dashboard' do
        response = [302, { 'Location' => '/dashboard' }, []]
        expect(subject.finish(env)).to eq(response)
      end
    end

    context '#subject' do
      let(:attrs) do
        attributes_for(:subject)
      end

      context 'for an unknown subject' do
        it 'creates the subject' do
          expect { subject.subject(env, attrs) }
            .to change(Subject, :count).by(1)
        end

        it 'returns the new subject' do
          obj = subject.subject(env, attrs)
          expect(obj).to be_a(Subject)
          expect(obj).to have_attributes(attrs.except(:audit_comment))
        end

        it 'records an audit record' do
          expect { subject.subject(env, attrs) }
            .to change(Audited.audit_class, :count).by(1)
        end

        it 'records the subject as the user in the audit record' do
          obj = subject.subject(env, attrs)
          expect(obj.audits.last.user).to eq(obj)
        end

        it 'marks the new subject as complete' do
          expect(subject.subject(env, attrs)).to be_complete
        end
      end

      context 'with an existing subject' do
        let!(:object) { create(:subject, attrs.merge(complete: false)) }

        it 'updates the attributes' do
          attrs = attributes_for(:subject).slice(:name, :mail, :shared_token)
          subject.subject(env, attrs)
          expect(object.reload).to have_attributes(attrs)
        end

        it 'returns the existing subject' do
          expect(subject.subject(env, attrs)).to eq(object)
        end

        it 'records an audit record on update' do
          expect { subject.subject(env, attrs.merge(name: 'Changed')) }
            .to change(Audited.audit_class, :count).by(1)
        end

        it 'records the subject as the user in the audit record' do
          obj = subject.subject(env, attrs.merge(name: 'Changed'))
          expect(obj.audits.last.user).to eq(obj)
        end

        it 'does not record an audit record when nothing changes' do
          object.without_auditing { object.update_attributes!(complete: true) }
          expect { subject.subject(env, attrs) }
            .not_to change(Audited.audit_class, :count)
        end

        it 'marks the subject as complete' do
          expect(subject.subject(env, attrs)).to be_complete
        end
      end

      context 'with an invite code' do
        let!(:invitation) { create(:invitation) }
        let(:attrs) { attributes_for(:subject) }
        let(:env) { { 'rack.session' => { invite: invitation.identifier } } }

        it 'does not create a subject' do
          expect { subject.subject(env, attrs) }.not_to change(Subject, :count)
        end

        it 'returns the existing subject' do
          expect(subject.subject(env, attrs)).to eq(invitation.subject)
        end

        it 'updates the attributes' do
          expected = attrs.except(:invite, :complete, :audit_comment)
          expect(subject.subject(env, attrs)).to have_attributes(expected)
        end

        it 'completes the subject' do
          expect { subject.subject(env, attrs) }
            .to change { invitation.subject.reload.complete? }.to true
        end

        it 'marks the invite as used' do
          expect { subject.subject(env, attrs) }
            .to change { invitation.reload.used? }.to true
        end

        it 'records an audit record' do
          expect { subject.subject(env, attrs) }
            .to change(Audited.audit_class, :count).by_at_least(1)
        end

        it 'records the subject as the user in the audit record' do
          obj = subject.subject(env, attrs)
          expect(obj.audits.last.user).to eq(obj)
        end

        context 'when the invitation fails to save' do
          before do
            allow_any_instance_of(Invitation).to receive(:update_attributes!)
              .and_raise('an failure')
          end

          it 'preserves the subject' do
            expect { subject.subject(env, attrs) }
              .to raise_error(/an failure/)
              .and not_change { invitation.subject.reload.attributes }
          end
        end

        context 'when the subject fails to save' do
          before do
            allow_any_instance_of(Subject).to receive(:update_attributes!)
              .and_raise('an failure')
          end

          it 'preserves the invite' do
            expect { subject.subject(env, attrs) }
              .to raise_error(/an failure/)
              .and not_change { invitation.reload.attributes }
          end
        end
      end
    end
  end
end
