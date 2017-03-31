# frozen_string_literal: true

module Authentication
  class ErrorHandler
    def handle(_env, e)
      raise(e)
    end
  end
end
