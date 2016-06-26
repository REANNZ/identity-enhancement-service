class APISubjectRoleAssignmentsController < ApplicationController
  before_action do
    @provider = Provider.find(params[:provider_id])
    @role = Role.find(params[:role_id])
  end

  def new
    check_access!("providers:#{@provider.id}:roles:grant")
    @filter = params[:filter]
    @api_subjects = APISubject.where.not(id: current_member_ids).filter(@filter)
                              .order(:x509_cn).paginate(page: params[:page])
    @assoc = @role.api_subject_role_assignments.new
  end

  def create
    check_access!("providers:#{@provider.id}:roles:grant")
    audit_attrs = { audit_comment: 'Granted role from providers interface' }
    @assoc = @role.api_subject_role_assignments
                  .create!(assoc_params.merge(audit_attrs))

    flash[:success] = creation_message(@assoc)

    redirect_to(provider_role_path(@provider, @role))
  end

  def destroy
    check_access!("providers:#{@provider.id}:roles:revoke")
    @assoc = @role.api_subject_role_assignments.find(params[:id])
    @assoc.audit_comment = 'Revoked role from providers interface'
    @assoc.destroy!

    flash[:success] = deletion_message(@assoc)

    redirect_to(provider_role_path(@provider, @role))
  end

  private

  def assoc_params
    params.require(:api_subject_role_assignment).permit(:api_subject_id)
  end

  def creation_message(assoc)
    "Granted #{@role.name} at #{@provider.name} to API Account: " \
      "#{assoc.api_subject.x509_cn}"
  end

  def current_member_ids
    @role.api_subject_role_assignments.map { |ra| ra.api_subject.id }
  end

  def deletion_message(assoc)
    "Revoked #{@role.name} at #{@provider.name} from API Account: " \
      "#{assoc.api_subject.x509_cn}"
  end
end
