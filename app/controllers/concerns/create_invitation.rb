module CreateInvitation
  delegate :image_url, to: :view_context

  def create_invitation(provider, subject_attrs, expires)
    Invitation.transaction do
      audit_attrs = {
        audit_comment: 'Created incomplete Subject for Invitation'
      }

      subject = Subject.create!(subject_attrs.merge(audit_attrs))
      invitation = provider.invite(subject, expires)
      deliver(invitation)
      subject
    end
  end

  def deliver(invitation)
    Mail.deliver(to: invitation.mail,
                 from: Rails.application.config.ide_service.mail[:from],
                 subject: 'Invitation to AAF Identity Enhancement',
                 body: email_message(invitation).render,
                 content_type: 'text/html; charset=UTF-8')

    invitation.update_attributes!(last_sent_at: Time.now,
                                  audit_comment: 'Redelivered invitation')

    self
  end

  private

  def email_message(invitation)
    Lipstick::EmailMessage.new(title: 'AAF Identity Enhancement',
                               image_url: image_url('email_branding.png'),
                               content: email_body(invitation))
  end

  EMAIL_BODY = File.read(Rails.root.join('config/invitation.md')).freeze

  def email_body(invitation)
    format(EMAIL_BODY,
           url: accept_invitations_url(identifier: invitation.identifier),
           expires: invitation.expires.strftime('%d/%m/%Y'))
  end
end
