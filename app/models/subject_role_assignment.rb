# frozen_string_literal: true

class SubjectRoleAssignment < ActiveRecord::Base
  audited comment_required: true, associated_with: :subject

  belongs_to :subject
  belongs_to :role

  valhammer

  validates :role, uniqueness: { scope: :subject }
end
