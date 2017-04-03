# frozen_string_literal: true

require 'active_record'

module ActiveRecord
  class Base
    def destroyed_by_association=(association)
      if respond_to?(:audit_comment=)
        self.audit_comment = 'Deleted automatically because parent ' \
                             "#{association.active_record.name} was deleted"
      end

      super
    end
  end
end
