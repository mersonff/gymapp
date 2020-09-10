class SkinfoldsController < ApplicationController
  before_action :set_client
  before_action :set_skinfold, only: [:edit, :update, :show, :destroy]
  before_action :require_user, except: [:index, :show]
  before_action :require_same_user, only: [:edit, :update, :destroy]
  
  def index
    @skinfolds = @client.skinfolds.paginate(page: params[:page], per_page: 5)
  end
  
  def new
    @skinfold = @client.skinfolds.build
  end
  
  def edit
  end
  
  def create
    @skinfold = @client.skinfolds.build(skinfold_params)
    if @skinfold.save
      flash[:success] = "Adipometria criada com sucesso"
      redirect_to client_path(@client)
    else
      render 'new'
    end
  end
  
  def update
    if @skinfold.update(skinfold_params)
      flash[:success] = "Adipometria atualizada com sucesso"
      redirect_to client_path(@client)
    else
      render 'edit'
    end
  end
  
  def show
  end
  
  def destroy
    @skinfold.destroy
    flash[:danger] = "Adipometria deletada com sucesso"
    redirect_to client_path(@client)
  end
  
  private
  
  def set_skinfold
    @skinfold = @client.skinfolds.find(params[:id])
  end
  
  def set_client
    @client = Client.find(params[:client_id])
  end
  
  def skinfold_params
    params.require(:skinfold).permit(:chest, :midaxilary, :subscapular, :bicep, :tricep, 
    :abdominal, :suprailiac, :thigh, :calf, :client_id)
  end

  def require_same_user
    if current_user != @skinfold.client.user && !current_user.admin?
      flash[:danger] = "Você não possui acesso a esse dado"
      redirect_to root_path
    end
  end
end