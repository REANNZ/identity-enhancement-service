class SubjectsController < ApplicationController
  # @subject is the current user. We use @objects and @object to sidestep that.

  def index
    check_access!('admin:subjects:list')
    @filter = params[:filter]
    @objects = Subject.filter(@filter).order(:name)
               .paginate(page: params[:page])
  end

  def show
    check_access!('admin:subjects:read')
    @object = Subject.find(params[:id])
  end

  def destroy
    check_access!('admin:subjects:delete')
    @object = Subject.find(params[:id])
    @object.audit_comment = 'Deleted from admin interface'
    @object.destroy!

    flash[:success] = "Deleted subject #{@object.name}"

    redirect_to(subjects_path)
  end

  def audits
    check_access!('admin:subjects:audit')
    @object = Subject.find(params[:id])
    @audits = @object.audits.all
  end
end
