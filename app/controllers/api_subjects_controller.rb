class APISubjectsController < ApplicationController
  before_action { @provider = Provider.find(params[:provider_id]) }

  def index
    check_access!("providers:#{@provider.id}:api_subjects:list")
    @api_subjects = @provider.api_subjects.all
  end

  def new
    check_access!("providers:#{@provider.id}:api_subjects:create")
    @api_subject = @provider.api_subjects.new
    @api_subject.contact_name = @subject.name
    @api_subject.mail = @subject.mail
  end

  def create
    check_access!("providers:#{@provider.id}:api_subjects:create")
    audit_attrs = { audit_comment: 'Created from providers interface' }
    @api_subject = @provider.api_subjects.create!(
      api_subject_params.merge(audit_attrs))
    redirect_to([@provider, :api_subjects])
  end

  def edit
    check_access!("providers:#{@provider.id}:api_subjects:update")
    @api_subject = @provider.api_subjects.find(params[:id])
  end

  def update
    check_access!("providers:#{@provider.id}:api_subjects:update")
    audit_attrs = { audit_comment: 'Updated from providers interface' }
    @api_subject = @provider.api_subjects.find(params[:id])
    @api_subject.update_attributes!(api_subject_params.merge(audit_attrs))
    redirect_to([@provider, :api_subjects])
  end

  def show
    check_access!("providers:#{@provider.id}:api_subjects:read")
    @api_subject = @provider.api_subjects.find(params[:id])
  end

  def destroy
    check_access!("providers:#{@provider.id}:api_subjects:delete")
    @api_subject = @provider.api_subjects.find(params[:id])
    @api_subject.audit_comment = 'Deleted from provider interface'
    @api_subject.destroy!
    redirect_to(provider_api_subjects_path(@provider))
  end

  def audits
    check_access!("providers:#{@provider.id}:api_subjects:audit")
    @api_subject = @provider.api_subjects.find(params[:id])
    @audits = @api_subject.audits.all
  end

  private

  def api_subject_params
    params.require(:api_subject)
      .permit(:x509_cn, :name, :description, :contact_name, :mail)
  end
end
