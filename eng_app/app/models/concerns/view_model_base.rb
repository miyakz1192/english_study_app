module ViewModelBase
  def view_model
    #@view_model if @view_model
    @view_model = eval "#{self.class.name}ViewModel.new(self)"
  end
private
  @view_model = nil
end
