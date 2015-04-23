class ProvisionedSubject < ActiveRecord::Base
  belongs_to :subject
  belongs_to :provider

  valhammer

  validates :provider, uniqueness: { scope: :subject }
end
