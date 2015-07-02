v1 = APIConstraints.new(version: 1)
Mime::Type.register v1.version_string, :ide_v1

# Rails' default exception handler uses the presence of "to_#{format}" to detect
# whether an error response can be rendered directly in that format. If not, it
# falls back to HTML.
#
# This allows the IdE API content type to correctly receive JSON errors.
module ToIDEVersion1
  def to_ide_v1
    to_json
  end
end

Hash.include(ToIDEV1)
