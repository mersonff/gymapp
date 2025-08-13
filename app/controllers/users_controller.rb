class UsersController < ApplicationController
  layout 'auth', only: [:new]
  before_action :set_user, only: [:edit, :update, :show]
  before_action :require_same_user_and_admin, only: [:edit, :update, :destroy]
  before_action :require_same_user, only: [:show]
  before_action :require_admin, only: [:create, :destroy]

  def index
    @users = User.paginate(page: params[:page], per_page: 5)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      flash[:success] = "Bem-vindo ao GymApp #{@user.username}"
      redirect_to user_path(@user)
    else
      flash[:danger] = "Erro ao criar usuário: #{@user.errors.full_messages.join(', ')}"
      redirect_to signup_path
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      flash[:success] = "Sua conta foi atualizada com sucesso"
      redirect_to user_path(@user)
    else
      flash[:danger] = "Erro ao atualizar usuário: #{@user.errors.full_messages.join(', ')}"
      redirect_to edit_user_path(@user)
    end
  end

  def show
    @user_plans = @user.plans.paginate(page: params[:page], per_page: 5)
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    flash[:danger] = "Usuário e Planos criados por ele foram deletados"
    redirect_to users_path
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:username, :business_name, :email, :password, :email_confirmation, :password_confirmation)
  end

  def require_same_user_and_admin
    if current_user != @user && !current_user.admin?
      flash[:danger] = "Você só pode editar sua própria conta"
      redirect_to root_path
    end
  end

  def require_same_user
    if current_user != @user
      flash[:danger] = "Você só pode editar sua própria conta"
      redirect_to root_path
    end
  end

  def require_admin
    if logged_in? && !current_user.admin?
      flash[:danger] = "Você não possui permissão para essa ação"
      redirect_to root_path
    end
  end

  def check_logged_in
    if logged_in?
      flash[:danger] = "Você já está logado!"
      redirect_to root_path
    end
  end

end
