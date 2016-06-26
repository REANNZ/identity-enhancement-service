class RequestedEnhancementsController < ApplicationController
  delegate :image_url, to: :view_context

  before_action(except: :select_provider) do
    @provider = Provider.find(params[:provider_id])
  end

  def index
    check_access!("providers:#{@provider.id}:attributes:list")
    @requested_enhancements = @provider.requested_enhancements.pending.all
  end

  def show
    check_access!("providers:#{@provider.id}:attributes:list")
    @requested_enhancement = @provider.requested_enhancements.find(params[:id])
    @provided_attributes =
      @requested_enhancement.subject.provided_attributes.for_provider(@provider)
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
    flash[:success] = 'Your request for identity enhancement has been sent ' \
                      "to #{@provider.name}"

    deliver(@requested_enhancement)

    redirect_to dashboard_path
  end

  def dismiss
    check_access!("providers:#{@provider.id}:attributes:create")
    @requested_enhancement = @provider.requested_enhancements.find(params[:id])

    @requested_enhancement.update_attributes!(
      actioned: true, actioned_by: subject,
      audit_comment: 'Actioned enhancement request via web'
    )

    flash[:success] = "Request from #{@requested_enhancement.subject.name} " \
                      'has been dismissed.'
    redirect_to [@provider, :requested_enhancements]
  end

  def select_provider
    public_action
    @filter = params[:filter]
    @providers = Provider.visible_to(subject).filter(@filter).order(:name)
                         .paginate(page: params[:page])
  end

  private

  def requested_enhancement_params
    params.require(:requested_enhancement).permit(:message)
  end

  def deliver(req)
    recipients = email_recipients
    return if recipients.empty?

    Mail.deliver(to: recipients,
                 from: Rails.application.config.ide_service.mail[:from],
                 subject: 'New Enhancement Request - AAF Identity Enhancement',
                 body: email_message(req).render,
                 content_type: 'text/html; charset=UTF-8')
  end

  def email_message(req)
    Lipstick::EmailMessage.new(title: 'AAF Identity Enhancement',
                               image_url: image_url('email_branding.png'),
                               content: email_body(req))
  end

  def email_recipients
    Subject
      .joins(:roles)
      .where(roles: { provider_id: @provider.id })
      .includes(roles: :permissions)
      .select { |u| u.permits?("providers:#{@provider.id}:attributes:list") }
      .map(&:mail)
  end

  EMAIL_BODY = File.read(Rails.root.join('config/enhancement_request.md'))
                   .freeze

  def email_body(req)
    format(EMAIL_BODY,
           url: url_for([@provider, req]),
           provider: @provider.name,
           name: req.subject.name,
           mail: req.subject.mail)
  end
end
