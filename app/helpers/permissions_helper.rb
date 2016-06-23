# frozen_string_literal: true
module PermissionsHelper
  def permitted?(action)
    @subject && @subject.permits?(action)
  end
end
