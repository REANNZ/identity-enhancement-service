# frozen_string_literal: true

module API
  class AttributesController < APIController
    include CreateInvitation

    def show
      logger.info("Request to #{request.path} from Provider " \
                  "#{@subject.provider_id}, API Subject #{@subject.x509_cn}")

      check_access!('api:attributes:read')
      @object = Subject.find_by_shared_token!(params[:shared_token])

      @provided_attributes = filter_attributes(
        @object.provided_attributes.includes(permitted_attribute: :provider)
      )
    end

    def create
      check_access!('api:attributes:create')
      Subject.transaction do
        @provider = lookup_provider(params[:provider])
        @object = provision_subject(@provider, params[:subject])

        params[:attributes].each do |attribute|
          update_attribute(@provider, @object,
                           attribute.permit(:name, :value, :public, :_destroy))
        end

        render status: :no_content, nothing: true
      end
    end

    private

    def filter_attributes(attributes)
      attributes.select do |attr|
        provider_id = attr.permitted_attribute.provider_id
        attr.public? ||
          subject.permits?("providers:#{provider_id}:attributes:read")
      end
    end

    def provision_subject(provider, attrs)
      subject = lookup_subject(provider, attrs)

      provisioned_subject = subject.provision(provider)
      return subject unless params.key?(:expires)

      provisioned_subject.update_attributes!(expires_at: params[:expires])
      subject
    end

    def update_attribute(provider, subject, opts)
      return destroy_attribute(provider, subject, opts) if opts[:_destroy]
      create_attribute(provider, subject, opts)
    end

    def create_attribute(provider, subject, opts)
      permitted_attribute = lookup_permitted_attribute(provider, opts)

      audit_attrs = { audit_comment: 'Provided attribute via API call' }
      subject.provided_attributes.create_with(opts.merge(audit_attrs))
             .find_or_create_by!(permitted_attribute: permitted_attribute)
    end

    def destroy_attribute(provider, subject, opts)
      permitted_attribute = lookup_permitted_attribute(provider,
                                                       opts.except(:_destroy))

      attribute = subject.provided_attributes
                         .find_by(permitted_attribute: permitted_attribute)

      return if attribute.nil?
      attribute.audit_comment = 'Revoked attribute via API call'
      attribute.destroy!
    end

    def lookup_permitted_attribute(provider, opts)
      permitted_attribute =
        provider.permitted_attributes.joins(:available_attribute)
                .find_by(available_attributes: opts.slice(:name, :value))

      permitted_attribute ||
        raise(BadRequest, "#{provider.name} is not permitted to provide " \
                         "#{opts[:name]} with value #{opts[:value]}")
    end

    def lookup_provider(opts)
      if opts.try(:[], :identifier).nil?
        raise(BadRequest, 'The Provider is not properly identified')
      end

      provider = Provider.lookup(opts[:identifier])
      check_access!("providers:#{provider.id}:attributes:create") if provider
      provider || raise(BadRequest, 'The specified Provider was not found')
    end

    def lookup_subject(provider, attrs)
      return find_or_create_by_shared_token(attrs) if attrs[:shared_token]
      find_or_create_by_invitation(provider, attrs)
    end

    def find_or_create_by_shared_token(attrs)
      subject = Subject.find_by_shared_token(attrs[:shared_token])

      return subject if subject
      return create_by_shared_token(attrs) if attrs[:allow_create]
      raise(BadRequest, 'The Subject was not known to this system')
    end

    def create_by_shared_token(attrs)
      audit_attrs = { audit_comment: 'Created via API call with shared_token' }

      Subject.create!(attrs.permit(:name, :mail, :shared_token)
                      .merge(audit_attrs))
    end

    def find_or_create_by_invitation(provider, attrs)
      name, mail = attrs.values_at(:name, :mail)

      raise(BadRequest, 'The Subject name is required') if name.nil?
      raise(BadRequest, 'The Subject email address is required') if mail.nil?

      Subject.find_by_mail(mail) || invite_subject(provider, attrs)
    end

    def invite_subject(provider, attrs)
      raise(BadRequest, 'The Subject was not found') unless attrs[:allow_create]

      expires = attrs[:expires] || 4.weeks.from_now.to_date
      create_invitation(provider, attrs.permit(:name, :mail), expires)
    end
  end
end
