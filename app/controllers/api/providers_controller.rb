module API
  class ProvidersController < APIController
    def index
      public_action

      @providers = Provider.visible_to(subject)
    end
  end
end
