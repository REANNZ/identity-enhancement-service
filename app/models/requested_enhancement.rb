class RequestedEnhancement < ActiveRecord::Base
  audited comment_required: true
  has_associated_audits

  belongs_to :subject
  belongs_to :provider
  belongs_to :actioned_by, class_name: 'Subject'

  valhammer

  validates :actioned_by, presence: { if: :actioned? },
                          absence: { unless: :actioned? }
end
