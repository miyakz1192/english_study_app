

module ViewModelBase
  #require "#{Rails.root}/app/models/view_model/user_view_model.rb"
  load "#{Rails.root}/app/models/view_model/user_view_model.rb"

  def view_model
    #@view_model if @view_model
    @view_model = eval "#{self.class.name}ViewModel.new(self)"
  end
private
  @view_model = nil
end
