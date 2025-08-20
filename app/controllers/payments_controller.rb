class PaymentsController < ApplicationController
  before_action :set_client
  before_action :set_payment, only: %i[edit update show destroy]
  before_action :require_user, except: %i[index show]
  before_action :require_same_user, only: %i[edit update destroy]

  def index
    @payments = @client.payments.order(payment_date: :desc).paginate(page: params[:page], per_page: 5)
  end

  def show; end

  def new
    @payment = @client.payments.build
    client = Client.find(@client.id)
    @start_date = [client.payments.last.payment_date + 1.month, Date.current].max
  end

  def edit; end

  def create
    @payment = @client.payments.build(payment_params)
    if @payment.save
      flash[:success] = 'Pagamento criado com sucesso'
      redirect_to client_path(@client)
    else
      render 'new'
    end
  end

  def update
    if @payment.update(payment_params)
      flash[:success] = 'Pagamento atualizado com sucesso'
      redirect_to client_path(@client)
    else
      render 'edit'
    end
  end

  def destroy
    @payment.destroy
    flash[:danger] = 'Pagamento deletado com sucesso'
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
    params.expect(payment: %i[payment_date value client_id])
  end

  def require_same_user
    return unless current_user != @payment.client.user && !current_user.admin?

    flash[:danger] = 'Você não possui acesso a esse dado'
    redirect_to home_path
  end
end
