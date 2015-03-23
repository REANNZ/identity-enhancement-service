class Subject < ActiveRecord::Base
  audited comment_required: true
  has_associated_audits

  include Accession::Principal

  has_many :subject_role_assignments, dependent: :destroy
  has_many :roles, through: :subject_role_assignments
  has_many :provided_attributes, dependent: :destroy
  has_many :invitations, dependent: :destroy

  valhammer

  validates :targeted_id, :shared_token, presence: true, if: :complete?

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

      other.reload # HACK: Why is this needed? Tests fail without it.
      other.audit_comment = "Merged into Subject #{id}"
      other.destroy!
    end
  end

  def functioning?
    enabled?
  end

  private

  def merge_roles(other)
    other.subject_role_assignments.each do |role_assoc|
      role_assoc.audit_comment = "Merged role into Subject #{id}"
      role_assoc.destroy!

      next if role_ids.include?(role_assoc.role_id)

      subject_role_assignments
        .create!(role: role_assoc.role,
                 audit_comment: "Merged role from Subject #{other.id}")
    end
  end

  def merge_attributes(other)
    other.provided_attributes.each do |other_attr|
      other_attr.audit_comment = "Merged attribute into Subject #{id}"
      other_attr.destroy!

      attrs = other_attr.attributes
              .slice(*%w(name value permitted_attribute_id))

      next if provided_attributes.where(attrs).any?

      attrs.merge!(audit_comment: "Merged attribute from Subject #{other.id}")
      provided_attributes.create!(attrs)
    end
  end
end
