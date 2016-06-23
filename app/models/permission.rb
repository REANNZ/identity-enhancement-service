# frozen_string_literal: true
class Permission < ActiveRecord::Base
  include Lipstick::AutoValidation

  audited comment_required: true, associated_with: :provider

  belongs_to :role
  delegate :provider, to: :role

  valhammer

  validates :value, format: Accession::Permission.regexp
end
