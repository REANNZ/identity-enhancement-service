class Provider < ActiveRecord::Base
  include Lipstick::AutoValidation
  include Lipstick::Filterable

  audited comment_required: true
  has_associated_audits

  has_many :roles, dependent: :destroy
  has_many :permitted_attributes, dependent: :destroy
  has_many :api_subjects, dependent: :destroy
  has_many :requested_enhancements, dependent: :destroy
  has_many :provisioned_subjects, dependent: :destroy

  valhammer

  validates :identifier, format: /\A[\w-]{1,40}\z/, length: { maximum: 40 }

  has_many :invitations

  filterable_by :name, :identifier

  def self.identifier_prefix
    Rails.application.config.ide_service.provider_prefix
  end

  def self.lookup(identifier)
    re = /\A#{identifier_prefix}:(.*)\z/
    find_by_identifier(Regexp.last_match[1]) if re.match(identifier)
  end

  def self.visible_to(user)
    return all if user.permits?('admin:providers:list')
    return visible_to_api_subject(user) if user.is_a?(APISubject)
    visible_to_subject(user)
  end

  def self.visible_to_subject(user)
    distinct
      .joins('left outer join roles on providers.id = roles.provider_id')
      .joins('left outer join subject_role_assignments ' \
             'on roles.id = subject_role_assignments.role_id ' \
             "and subject_role_assignments.subject_id = #{user.id}")
      .where('providers.public = 1 or subject_role_assignments.id is not null')
  end

  def self.visible_to_api_subject(user)
    distinct
      .joins('left outer join roles on providers.id = roles.provider_id')
      .joins('left outer join api_subject_role_assignments ' \
             'on roles.id = api_subject_role_assignments.role_id ' \
             "and api_subject_role_assignments.api_subject_id = #{user.id}")
      .where('providers.public = 1 ' \
             'or api_subject_role_assignments.id is not null')
  end

  def full_identifier
    [Provider.identifier_prefix, identifier].join(':')
  end

  def invite(subject, expires)
    identifier = SecureRandom.urlsafe_base64(19)

    message = "Created invitation for #{subject.name}"

    attrs = { subject_id: subject.id, identifier: identifier,
              name: subject.name, mail: subject.mail, expires: expires,
              last_sent_at: Time.zone.now, audit_comment: message }

    invitations.create!(attrs)
  end

  DEFAULT_ROLES = {
    'API Read Only' => %w(
      api:attributes:read
      providers:PROVIDER_ID:attributes:read
    ),
    'API Read/Write' => %w(
      api:attributes:*
      providers:PROVIDER_ID:attributes:*
    ),
    'Web UI Read Only' => %w(
      providers:PROVIDER_ID:list
      providers:PROVIDER_ID:read
    ),
    'Web UI Read/Write' => %w(
      providers:PROVIDER_ID:list
      providers:PROVIDER_ID:read
      providers:PROVIDER_ID:invitations:*
      providers:PROVIDER_ID:attributes:*
    ),
    'Administrator' => %w(
      providers:PROVIDER_ID:*
    )
  }.freeze

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
