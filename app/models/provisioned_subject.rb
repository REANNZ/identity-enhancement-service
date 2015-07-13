class ProvisionedSubject < ActiveRecord::Base
  audited

  belongs_to :subject
  belongs_to :provider

  valhammer

  validates :provider, uniqueness: { scope: :subject }

  scope :expired, -> { where(arel_table[:expires_at].lt(Time.now.utc)) }
end
