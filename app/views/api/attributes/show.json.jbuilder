json.subject do
  json.call(@object, :shared_token, :name, :mail)
end

json.attributes @provided_attributes do |attr|
  json.name attr.name
  json.value attr.value
  json.provider attr.permitted_attribute.provider.full_identifier
end
