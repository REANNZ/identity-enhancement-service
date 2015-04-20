class RequestedEnhancement < ActiveRecord::Base
  include Lipstick::AutoValidation

  audited comment_required: true
  has_associated_audits

  belongs_to :subject
  belongs_to :provider
  belongs_to :actioned_by, class_name: 'Subject'

  scope :pending, -> { where(actioned: false) }

  valhammer

  validates :actioned_by, presence: { if: :actioned? },
                          absence: { unless: :actioned? }
end
