class PaymentsController < ApplicationController
  before_action :set_client
  before_action :set_payment, only: [:edit, :update, :show, :destroy]
  before_action :require_user, except: [:index, :show]
  before_action :require_same_user, only: [:edit, :update, :destroy]
  
  def index
    @payments = @client.payments.paginate(page: params[:page], per_page: 5)
  end
  
  def new
    @payment = @client.payments.build
    client = Client.find(@client.id)
    if client.payments.last.payment_date + 1.month <= Date.today
      @start_date = Date.today
    else
      @start_date = client.payments.last.payment_date + 1.month
    end
  end
  
  def edit
  end
  
  def create
    @payment = @client.payments.build(payment_params)
    if @payment.save
      flash[:success] = "Payment was created successfully"
      redirect_to client_path(@client)
    else
      render 'new'
    end
  end
  
  def update
    if @payment.update(payment_params)
      flash[:success] = "Payment was successfully updated"
      redirect_to client_path(@client)
    else
      render 'edit'
    end
  end
  
  def show
  end
  
  def destroy
    @payment.destroy
    flash[:danger] = "Payment was successfully deleted"
    redirect_to client_path(@client)
  end
  
  private
  
  def set_payment
    @payment = @client.payments.find(params[:id])
  end
  
  def set_client
    @client = Client.find(params[:client_id])
  end
  
  def payment_params
    params.require(:payment).permit(:payment_date, :value, :client_id)
  end

  def require_same_user
    if current_user != @payment.client.user && !current_user.admin?
      flash[:danger] = "You can only edit or delete your own Payment"
      redirect_to root_path
    end
  end
end