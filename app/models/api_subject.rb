class APISubject < ActiveRecord::Base
  include Accession::Principal
  include Lipstick::AutoValidation
  include Lipstick::Filterable

  audited comment_required: true
  has_associated_audits

  belongs_to :provider

  has_many :api_subject_role_assignments, dependent: :destroy
  has_many :roles, through: :api_subject_role_assignments

  valhammer

  validates :x509_cn, format: /\A[\w-]+\z/

  filterable_by :x509_cn, :description

  @lipstick_field_names = { x509_cn: 'X.509 CN' }

  def permissions
    roles.flat_map { |role| role.permissions.map(&:value) }
  end

  def functioning?
    enabled?
  end

  def contact_details
    { name: contact_name, mail: contact_mail }
  end
end
