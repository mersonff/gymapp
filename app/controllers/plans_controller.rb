class PlansController < ApplicationController
  before_action :require_user, except: [:index]
  before_action :set_plan, only: %i[edit update destroy]
  before_action :require_same_user, only: %i[edit update destroy]

  def index
    @plans = current_user.plans.paginate(page: params[:page], per_page: 5)
  end

  def new
    @plan = Plan.new
  end

  def edit; end

  def create
    @plan = Plan.new(plan_params)
    @plan.user = current_user
    if @plan.save
      flash[:success] = 'Plano criado com sucesso'
      redirect_to plans_path
    else
      flash[:danger] = "Erro ao criar plano: #{@plan.errors.full_messages.join(', ')}"
      redirect_to new_plan_path
    end
  end

  def update
    if @plan.update(plan_params)
      flash[:success] = 'Plano atualizado com sucesso'
      redirect_to plans_path
    else
      flash[:danger] = "Erro ao atualizar plano: #{@plan.errors.full_messages.join(', ')}"
      redirect_to edit_plan_path(@plan)
    end
  end

  def destroy
    if @plan&.destroy
      flash[:success] = 'Plano deletado com sucesso'
    else
      flash[:danger] = 'Erro ao deletar o plano'
    end
    redirect_to plans_path
  end

  private

  def set_plan
    @plan = Plan.find_by(id: params[:id])
    return if @plan

    flash[:danger] = 'Plano não encontrado'
    redirect_to plans_path
  end

  def plan_params
    params.expect(plan: %i[description value])
  end

  def require_same_user
    return unless @plan # Proteção caso o plano não exista

    return unless current_user != @plan.user && !current_user.admin?

    flash[:danger] = 'Você não possui acesso a esse dado'
    redirect_to root_path
  end
end
