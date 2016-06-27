# frozen_string_literal: true
class ProvidedAttribute < ActiveRecord::Base
  audited comment_required: true, associated_with: :subject

  belongs_to :permitted_attribute
  belongs_to :subject

  valhammer

  validates :permitted_attribute, uniqueness: { scope: :subject }
  validate :must_match_permitted_attribute

  def self.for_provider(provider)
    joins(:permitted_attribute)
      .where('permitted_attributes.provider_id' => provider.id)
  end

  def must_match_permitted_attribute
    return unless permitted_attribute
    attr = permitted_attribute.available_attribute

    errors.add(:name, 'must match the permitted name') if name != attr.name
    errors.add(:value, 'must match the permitted value') if value != attr.value
  end
end
