# frozen_string_literal: true
json.subject do
  json.call(@object, :shared_token, :name, :mail)
end

json.attributes @provided_attributes do |attr|
  provisioned_subject = @object.provisioned_subjects.to_a.find do |ps|
    ps.provider_id == attr.permitted_attribute.provider_id
  end

  json.name attr.name
  json.value attr.value
  json.provider attr.permitted_attribute.provider.full_identifier
  json.created attr.created_at.utc.xmlschema
  json.expires provisioned_subject.try(:expires_at).try(:utc).try(:xmlschema)
end
