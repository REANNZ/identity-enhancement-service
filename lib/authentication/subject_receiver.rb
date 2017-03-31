# frozen_string_literal: true

module Authentication
  class SubjectReceiver
    include RapidRack::DefaultReceiver
    include RapidRack::RedisRegistry

    def map_attributes(_env, attrs)
      {
        targeted_id: attrs['edupersontargetedid'],
        shared_token: attrs['auedupersonsharedtoken'],
        name: attrs['displayname'],
        mail: attrs['mail']
      }
    end

    def subject(env, attrs)
      session = env['rack.session']
      return accept_invitation(session, attrs) if session.try(:key?, :invite)

      subject_scope(attrs).find_or_initialize_by({}).tap do |subject|
        check_subject(subject, attrs)
        update_subject(subject, attrs)
      end
    end

    def finish(env)
      session = env['rack.session']
      if session&.delete(:invite)
        redirect_to('/invitations/complete')
      else
        redirect_to(session&.delete(:return_url) || '/dashboard')
      end
    end

    private

    def accept_invitation(session, attrs)
      invitation = Invitation.where(identifier: session[:invite])
                             .available.first!

      subject = subject_scope(attrs).first || invitation.subject
      Audited.audit_class.as_user(subject) do
        subject.accept(invitation, attrs)
      end

      subject
    end

    def update_subject(subject, attrs)
      subject.attributes = attrs.merge(complete: true)

      Audited.audit_class.as_user(subject) do
        if subject.new_record?
          subject.audit_comment = 'Provisioned account for initial login'
          subject.save!
        elsif subject.changed?
          subject.audit_comment = 'Updated attributes upon login'
          subject.save!
        end
      end
    end

    def subject_scope(attrs)
      t = Subject.arel_table
      Subject.where(t[:targeted_id].eq(attrs[:targeted_id])
        .or(t[:shared_token].eq(attrs[:shared_token])))
    end

    def check_subject(subject, attrs)
      require_nil_or_equal(subject.targeted_id, attrs[:targeted_id])
      require_nil_or_equal(subject.shared_token, attrs[:shared_token])
    end

    def require_nil_or_equal(actual, expected)
      return if actual.nil? || actual == expected
      raise("Unable to update Subject, incoming value `#{expected}` did not " \
           "match existing value `#{actual}`")
    end
  end
end
