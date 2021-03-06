# frozen_string_literal: true

class Invitation < ActiveRecord::Base
  include Lipstick::AutoValidation

  audited comment_required: true

  belongs_to :provider
  belongs_to :subject

  valhammer

  validates :identifier, format: /\A[\w-]+\z/
  validates :subject, uniqueness: true
  validate :must_not_be_preexpired

  scope :available, -> { where(used: false) }

  def expired?
    !used? && expires && expires < Time.zone.now
  end

  def must_not_be_preexpired
    return if persisted?
    errors.add(:expires, 'must be in the future') if expired?
  end
end
