# frozen_string_literal: true

class Role < ActiveRecord::Base
  include Lipstick::AutoValidation

  audited comment_required: true, associated_with: :provider
  has_associated_audits

  belongs_to :provider

  has_many :permissions, dependent: :destroy
  has_many :subject_role_assignments, dependent: :destroy
  has_many :api_subject_role_assignments, dependent: :destroy

  has_many :subjects, through: :subject_role_assignments
  has_many :api_subjects, through: :api_subject_role_assignments

  valhammer
end
