# frozen_string_literal: true
class PermittedAttribute < ActiveRecord::Base
  audited comment_required: true, associated_with: :provider

  belongs_to :provider
  belongs_to :available_attribute

  has_many :provided_attributes, dependent: :destroy

  valhammer

  validates :available_attribute, uniqueness: { scope: :provider }
end
