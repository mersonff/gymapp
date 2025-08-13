class SessionsController < ApplicationController
  layout 'auth', only: [:new]
  
  def new

  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      session[:user_id] = user.id
      flash[:success] = "Logado com sucesso"
      redirect_to home_path
    else
      flash[:danger] = "Há algo de errado com as informações fornecidas"
      redirect_to login_path
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:success] = "Você deslogou com sucesso"
    redirect_to login_path
  end
end
