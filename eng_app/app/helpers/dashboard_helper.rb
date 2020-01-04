module DashboardHelper
  def init
    @vm = current_user.view_model
    @dp = DashboardPresenter.new(current_user)
  end
end

