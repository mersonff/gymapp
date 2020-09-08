class PlansController < ApplicationController
  before_action :set_plan, only: [:edit, :update, :show, :destroy]
  before_action :require_user, except: [:index, :show]
  before_action :require_same_user, only: [:edit, :update, :destroy]
  
  def index
    @plans = current_user.plans.paginate(page: params[:page], per_page: 5)
  end
  
  def new
    @plan = Plan.new
  end
  
  def edit
  end
  
  def create
    @plan = Plan.new(plan_params)
    @plan.user = current_user
    if @plan.save
      flash[:success] = "Plan was created successfully"
      redirect_to user_path(current_user)
    else
      render 'new'
    end
  end
  
  def update
    if @plan.update(plan_params)
      flash[:success] = "Plan was successfully updated"
      redirect_to user_path(current_user)
    else
      render 'edit'
    end
  end
  
  def show
  end
  
  def destroy
    @plan.destroy
    flash[:danger] = "Plan was successfully deleted"
    redirect_to user_path(current_user)
  end
  
  private
  
  def set_plan
    @plan = Plan.find(params[:id])
  end
  
  def plan_params
    params.require(:plan).permit(:description, :value)
  end

  def require_same_user
    if current_user != @plan.user && !current_user.admin?
      flash[:danger] = "You can only edit or delete your own Plan"
      redirect_to root_path
    end
  end
end