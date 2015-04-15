class Provider < ActiveRecord::Base
  include Lipstick::AutoValidation

  audited comment_required: true
  has_associated_audits

  has_many :roles, dependent: :destroy
  has_many :permitted_attributes, dependent: :destroy
  has_many :api_subjects, dependent: :destroy

  valhammer

  validates :identifier, format: /\A[\w-]{1,40}\z/, length: { maximum: 40 }

  has_many :invitations

  def self.identifier_prefix
    Rails.application.config.ide_service.provider_prefix
  end

  def self.lookup(identifier)
    re = /\A#{identifier_prefix}:(.*)\z/
    find_by_identifier(Regexp.last_match[1]) if re.match(identifier)
  end

  def full_identifier
    [Provider.identifier_prefix, identifier].join(':')
  end

  def invite(subject, expires)
    identifier = SecureRandom.urlsafe_base64(19)

    message = "Created invitation for #{subject.name}"

    attrs = { subject_id: subject.id, identifier: identifier,
              name: subject.name, mail: subject.mail, last_sent_at: Time.now,
              expires: expires, audit_comment: message }

    invitations.create!(attrs)
  end

  DEFAULT_ROLES = {
    api_ro: %w(api:attributes:read),
    api_rw: %w(
      api:attributes:*
      providers:PROVIDER_ID:attributes:create
    ),
    web_ro: %w(
      providers:PROVIDER_ID:list
      providers:PROVIDER_ID:read
    ),
    web_rw: %w(
      providers:PROVIDER_ID:list
      providers:PROVIDER_ID:read
      providers:PROVIDER_ID:invitations:*
      providers:PROVIDER_ID:attributes:*
    ),
    admin: %w(
      providers:PROVIDER_ID:*
    )
  }

  private_constant :DEFAULT_ROLES

  def create_default_roles
    DEFAULT_ROLES.each do |name, permission_strings|
      without_auditing do
        role = roles.build(name: name)
        role.without_auditing { role.save! }
        permission_strings.each do |value|
          p = role.permissions.build(value: value.gsub(/PROVIDER_ID/, id.to_s))
          p.without_auditing { p.save! }
        end
      end
    end
  end
end
