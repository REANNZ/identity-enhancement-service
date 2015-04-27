class ProvidersController < ApplicationController
  def index
    public_action
    @filter = params[:filter]
    @providers = Provider.filter(@filter).order(:name)
                 .paginate(page: params[:page])
  end

  def new
    check_access!('providers:create')
    @provider = Provider.new
  end

  def create
    check_access!('providers:create')
    Provider.transaction do
      @provider = create_provider
      unless @provider.persisted?
        return form_error('new', 'Unable to create the Provider', @provider)
      end
    end

    flash[:success] = "Created provider: #{@provider.name}"
    redirect_to providers_path
  end

  def show
    check_access!("providers:#{params[:id]}:read")
    @provider = Provider.find(params[:id])
    @request_count = RequestedEnhancement.where(provider_id: @provider.id)
                     .pending.count
  end

  def edit
    check_access!("providers:#{params[:id]}:update")
    @provider = Provider.find(params[:id])
  end

  def update
    check_access!("providers:#{params[:id]}:update")

    @provider = Provider.find(params[:id])
    unless update_provider(@provider)
      return form_error('edit', 'Unable to save the Provider', @provider)
    end

    flash[:success] = "Updated provider: #{@provider.name}"
    redirect_to providers_path
  end

  def destroy
    check_access!('providers:delete')
    @provider = Provider.find(params[:id])
    @provider.audit_comment = 'Destroyed provider from admin interface'
    @provider.destroy!

    flash[:success] = "Deleted provider: #{@provider.name}"

    redirect_to providers_path
  end

  private

  def provider_params
    params.require(:provider).permit(:name, :description, :identifier, :public)
  end

  def create_provider
    audit_attrs = { audit_comment: 'Created new provider from admin interface' }
    provider = Provider.new(provider_params.merge(audit_attrs))

    provider.save && provider.create_default_roles
    provider
  end

  def update_provider(provider)
    audit_attrs = { audit_comment: 'Updated provider from admin interface' }
    provider.update_attributes(provider_params.merge(audit_attrs))
  end
end
