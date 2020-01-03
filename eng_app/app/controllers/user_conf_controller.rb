class UserConfController < ApplicationController
  before_action :authenticate_user!

  def toggle_mode
    @user = current_user
    if @user.mode == UserActionMode::NORMAL
      mode = UserActionMode::WORST
    else
      mode = UserActionMode::NORMAL
    end

    if @user.update({:mode => mode})
      redirect_to :edit_user_registration
    else
      @user.errors 
    end
  end

  def update
    update_aux(params)
  end

  def edit
    @user.errors 
  end

private
  def update_aux(parameters)
    respond_to do |format|
      if @user.update(parameters)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
end
