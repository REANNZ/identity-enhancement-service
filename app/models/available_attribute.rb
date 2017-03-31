# frozen_string_literal: true

class AvailableAttribute < ActiveRecord::Base
  include Lipstick::AutoValidation

  audited comment_required: true

  has_many :permitted_attributes, dependent: :restrict_with_error

  valhammer

  validates :name, inclusion: { in: %w(eduPersonEntitlement) }
  validates :value, format: /\Aurn:mace:aaf\.edu\.au:ide:([\w\.-]+:)*[\w\.-]+\z/

  def initialize(*)
    super
    self.name ||= 'eduPersonEntitlement'
    self.value ||= 'urn:mace:aaf.edu.au:ide:'
  end

  def self.audits
    Audited.audit_class.where(auditable_type: name)
  end
end
