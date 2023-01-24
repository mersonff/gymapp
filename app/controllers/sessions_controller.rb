class SessionsController < ApplicationController
  before_action :check_logged_in, only: [:old]


  def new

  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      session[:user_id] = user.id
      flash[:success] = "Logado com sucesso"
      redirect_to home_path
    else
      flash.now[:danger] = "Há algo de errado com as informações fornecidas"
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:success] = "Você deslogou com sucesso"
    redirect_to login_path
  end

  def check_logged_in
    if logged_in?
      flash[:danger] = "Você já está logado!"
      redirect_to home_path
    end
  end
end
