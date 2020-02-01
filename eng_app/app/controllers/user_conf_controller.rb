class UserConfController < ApplicationController
  before_action :authenticate_user!

  def toggle_mode
    @user = current_user
    if @user.update({:mode => next_mode(@user)})
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
  def next_mode(user)
    @user = current_user
    case @user.mode
    when UserActionMode::NORMAL
      return UserActionMode::TOP
    when UserActionMode::TOP
      return UserActionMode::WORST
    when UserActionMode::WORST
      return UserActionMode::NORMAL
    else
      return UserActionMode::NORMAL
    end
  end

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
