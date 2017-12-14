# frozen_string_literal: true

class Subject < ActiveRecord::Base
  audited comment_required: true
  has_associated_audits

  include Accession::Principal
  include Lipstick::Filterable

  has_many :subject_role_assignments, dependent: :destroy
  has_many :roles, through: :subject_role_assignments, inverse_of: false
  has_many :provided_attributes, dependent: :destroy
  has_many :requested_enhancements, dependent: :destroy
  has_many :provisioned_subjects, dependent: :destroy
  has_one :invitation, dependent: :nullify

  valhammer

  validates :targeted_id, :shared_token, presence: true, if: :complete?

  filterable_by :name, :mail

  def permissions
    subject_role_assignments.flat_map { |ra| ra.role.permissions.map(&:value) }
  end

  def accept(invitation, attrs)
    transaction do
      message = 'Provisioned account via invitation'
      update_attributes!(attrs.merge(audit_comment: message, complete: true))

      invited_subject = invitation.subject

      invitation.update_attributes!(used: true, subject: self,
                                    audit_comment: "Accepted by #{name}")

      merge(invited_subject) if invited_subject != self
    end
  end

  def merge(other)
    transaction do
      merge_roles(other)
      merge_attributes(other)

      other.audit_comment = "Merged into Subject #{id}"
      other.association(:invitation).reset
      other.destroy!
    end
  end

  def functioning?
    enabled?
  end

  def provision(provider)
    provisioned_subjects
      .create_with(audit_comment: 'Provisioned for new attribute')
      .find_or_create_by!(provider: provider)
  end

  def contact_details
    { name: name, mail: mail }
  end

  private

  def merge_roles(other)
    other.subject_role_assignments.each do |role_assoc|
      next if role_ids.include?(role_assoc.role_id)

      subject_role_assignments
        .create!(role: role_assoc.role,
                 audit_comment: "Merged role from Subject #{other.id}")
    end
  end

  def merge_attributes(other)
    other.provided_attributes.each do |other_attr|
      attrs = other_attr.attributes
                        .slice('name', 'value', 'permitted_attribute_id')

      next if provided_attributes.where(attrs).any?

      attrs[:audit_comment] = "Merged attribute from Subject #{other.id}"
      provided_attributes.create!(attrs)
    end
  end
end
