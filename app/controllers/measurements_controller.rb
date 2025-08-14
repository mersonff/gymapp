class MeasurementsController < ApplicationController
  before_action :set_client
  before_action :set_measurement, only: [:edit, :update, :show, :destroy]
  before_action :require_user, except: [:index, :show]
  before_action :require_same_user, only: [:edit, :update, :destroy]
  
  def index
    @measurements = @client.measurements.order('created_at DESC').paginate(page: params[:page], per_page: 5)
  end
  
  def new
    @measurement = @client.measurements.build
  end
  
  def edit
  end
  
  def create
    @measurement = @client.measurements.build(measurement_params)
    if @measurement.save
      flash[:success] = "Perimetria criada com sucesso"
      redirect_to client_path(@client)
    else
      render 'new'
    end
  end
  
  def update
    if @measurement.update(measurement_params)
      flash[:success] = "Perimetria atualizada com sucesso"
      redirect_to client_path(@client)
    else
      render 'edit'
    end
  end
  
  def show
  end
  
  def destroy
    @measurement.destroy
    flash[:danger] = "Perimetria deletada com sucesso"
    redirect_to client_path(@client)
  end
  
  private
  
  def set_measurement
    @measurement = @client.measurements.find(params[:id])
  end
  
  def set_client
    @client = Client.find(params[:client_id])
  end
  
  def measurement_params
    params.require(:measurement).permit(:height, :weight, :chest, :left_arm, :right_arm,
    :waist, :abdomen, :hips, :left_thigh, :righ_thigh, :client_id)
  end

  def require_same_user
    if current_user != @measurement.client.user && !current_user.admin?
      flash[:danger] = "Você não possui acesso a esse dado"
      redirect_to home_path
    end
  end
end