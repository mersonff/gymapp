class ClientsController < ApplicationController
  before_action :set_client, only: [:edit, :update, :show, :destroy]
  before_action :require_user, except: [:index, :show]
  before_action :require_same_user, only: [:edit, :update, :destroy]

  def index
      @clients = current_user.clients
  end

  def new
      @client = Client.new
      @client.measurements.build
      @client.skinfolds.build
      @client.payments.build
  end

  def edit

  end

  def create
    @client = Client.new(client_params)
    @client.user = current_user
    if @client.save
      flash[:success] = "Client was created successfully"
      redirect_to client_path(@client)
    else
      render 'new'
    end
  end

  def update
    if @client.update(client_params)
      flash[:success] = "Plan was successfully updated"
      redirect_to client_path(@client)
    else
      render 'edit'
    end
  end

  def show
    last_payment = @client.payments.last
    @day_of_payment = last_payment.payment_date + 1.month
    @client_payments = @client.payments.order('payment_date DESC').paginate(page: params[:page], per_page: 10)
    @client_measurements = @client.measurements.order('payment_date DESC').paginate(page: params[:page], per_page: 10)
    @client_skinfolds = @client.measurements.order('payment_date DESC').paginate(page: params[:page], per_page: 10)
  end

  def destroy
    @client.destroy
    flash[:danger] = "Client was successfully deleted"
    redirect_to clients_path
  end

  private

  def set_client
    @client = Client.find(params[:id])
  end

  def client_params
    params.require(:client).permit(:name, :birthdate, :address, :cellphone, :gender,
      measurements_attributes: [ :height, :weight, :chest, :left_arm, :right_arm, :waist, :abdomen, :hips, :left_thigh, :righ_thigh],
      skinfolds_attributes: [ :chest, :midaxilary, :subscapular, :bicep, :tricep, :abdominal, :suprailiac, :thigh, :calf],
      payments_attributes: [ :payment_date, :value ] )
  end

  def require_same_user
    if current_user != @client.user && !current_user.admin?
      flash[:danger] = "You can only edit or delete your own Client"
      redirect_to root_path
    end
  end
end