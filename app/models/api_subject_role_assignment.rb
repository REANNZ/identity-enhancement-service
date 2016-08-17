# frozen_string_literal: true
class APISubjectRoleAssignment < ActiveRecord::Base
  audited comment_required: true, associated_with: :api_subject

  belongs_to :api_subject
  belongs_to :role

  valhammer

  validates :role, uniqueness: { scope: :api_subject }
end
