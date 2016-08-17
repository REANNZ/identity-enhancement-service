# frozen_string_literal: true
class APIConstraints
  def initialize(version:, default: false)
    @version = version
    @default = default
  end

  def matches?(req)
    @default || req.headers['Accept'].include?(version_string)
  end

  def version_string
    "application/vnd.aaf.ide.v#{@version}+json"
  end
end
