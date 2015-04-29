module API
  class AttributesController < APIController
    include CreateInvitation

    def show
      check_access!('api:attributes:read')
      @object = Subject.find_by_shared_token(params[:shared_token])

      @provided_attributes = filter_attributes(
        @object.provided_attributes.includes(permitted_attribute: :provider))
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
      lookup_opts = opts.slice(:name, :value)

      permitted_attribute = provider.permitted_attributes
                            .joins(:available_attribute)
                            .find_by(available_attributes: lookup_opts)

      permitted_attribute ||
        fail(BadRequest, "#{provider.name} is not permitted to provide " \
                         "#{opts[:name]} with value #{opts[:value]}")
    end

    def lookup_provider(opts)
      if opts.nil? || opts[:identifier].nil?
        fail(BadRequest, 'The Provider is not properly identified')
      end

      provider = Provider.lookup(opts[:identifier])
      provider || fail(BadRequest, "The Provider #{opts[:identifier]} " \
                                   'was not found')

      check_access!("providers:#{provider.id}:attributes:create")
      provider
    end

    def lookup_subject(provider, attrs)
      if attrs[:shared_token]
        find_subject_by_shared_token(attrs[:shared_token])
      else
        find_or_create_subject(provider, attrs)
      end
    end

    def find_subject_by_shared_token(shared_token)
      Subject.find_by_shared_token(shared_token) ||
        fail(BadRequest, 'The Subject was not known to this system')
    end

    def find_or_create_subject(provider, attrs)
      name, mail = attrs.values_at(:name, :mail)

      if name.nil?
        fail(BadRequest, 'The Subject name was not provided, but is required')
      elsif mail.nil?
        fail(BadRequest, 'The Subject email address was not provided, ' \
                         'but is required')
      end

      Subject.find_by_mail(mail) || invite_subject(provider, attrs)
    end

    def invite_subject(provider, attrs)
      expires = attrs[:expires] || 4.weeks.from_now.to_date
      create_invitation(provider, attrs.permit(:name, :mail), expires)
    end
  end
end
