class RequestedEnhancementsController < ApplicationController
  before_action(except: :select_provider) do
    @provider = Provider.find(params[:provider_id])
  end

  def index
    check_access!("providers:#{@provider.id}:attributes:list")
    @requested_enhancements = @provider.requested_enhancements.all
  end

  def show
    check_access!("providers:#{@provider.id}:attributes:list")
    @requested_enhancement = @provider.requested_enhancements.find(params[:id])
  end

  def new
    public_action
    @requested_enhancement = @provider.requested_enhancements.new
  end

  def create
    public_action
    attrs = requested_enhancement_params
            .merge(audit_comment: 'Created enhancement request via web',
                   subject: subject)

    @requested_enhancement = @provider.requested_enhancements.create!(attrs)
    redirect_to @provider
  end

  def dismiss
    check_access!("providers:#{@provider.id}:attributes:create")
    @requested_enhancement = @provider.requested_enhancements.find(params[:id])

    @requested_enhancement.update_attributes!(
      actioned: true, actioned_by: subject,
      audit_comment: 'Actioned enhancement request via web')

    redirect_to [@provider, :requested_enhancements]
  end

  def update
    check_access!("providers:#{@provider.id}:attributes:create")
    @requested_enhancement = @provider.requested_enhancements.find(params[:id])
    attrs = requested_enhancement_params
            .merge(audit_comment: 'Edited enhancement request via web')
    @requested_enhancement.update_attributes!(attrs)
    redirect_to [@provider, :requested_enhancements]
  end

  def destroy
    public_action
    render nothing: true
  end

  def select_provider
    public_action
    @providers = Provider.all
  end

  private

  def requested_enhancement_params
    params.require(:requested_enhancement).permit(:message)
  end
end
