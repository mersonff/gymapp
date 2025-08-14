class ClientsController < ApplicationController
  before_action :set_client, only: [:edit, :update, :show, :destroy]
  before_action :require_user, except: [:index, :show]
  before_action :require_same_user, only: [:edit, :update, :destroy]

  def index
    @clients = current_user.clients
    
    # Calcular estatísticas antes de aplicar filtros
    @total_clients = @clients.joins(:payments).distinct.count
    @overdue_clients = @clients.joins(:payments)
      .where("payments.payment_date + INTERVAL '1 month' <= ?", Date.current)
      .group("clients.id")
      .having("MAX(payments.payment_date) = (SELECT MAX(p2.payment_date) FROM payments p2 WHERE p2.client_id = clients.id)")
      .count.size
    @current_clients = @total_clients - @overdue_clients
    
    # Filtrar inadimplentes se solicitado - usando apenas ActiveRecord/SQL
    if params[:filter] == 'overdue'
      @clients = @clients.joins(:payments)
        .where("payments.payment_date + INTERVAL '1 month' <= ?", Date.current)
        .group("clients.id")
        .having("MAX(payments.payment_date) = (SELECT MAX(p2.payment_date) FROM payments p2 WHERE p2.client_id = clients.id)")
    end
    
    @clients = @clients.paginate(page: params[:page], per_page: 10)
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
      flash[:success] = "Cliente criado com sucesso"
      redirect_to client_path(@client)
    else
      flash[:danger] = "Erro ao criar cliente: #{@client.errors.full_messages.join(', ')}"
      redirect_to new_client_path
    end
  end

  def update
    if @client.update(client_params)
      flash[:success] = "Cliente atualizado com sucesso"
      redirect_to client_path(@client)
    else
      flash[:danger] = "Erro ao atualizar cliente: #{@client.errors.full_messages.join(', ')}"
      redirect_to edit_client_path(@client)
    end
  end

  def show
    last_payment = @client.payments.last
    @day_of_payment = last_payment&.payment_date&.+ 1.month
    
    # Buscar apenas os 10 últimos de cada categoria
    @client_payments = @client.payments.order('payment_date DESC').limit(10)
    @client_measurements = @client.measurements.order('created_at DESC').limit(10)
    @client_skinfolds = @client.skinfolds.order('created_at DESC').limit(10)
    
    # Calcular IMC atual (última medição)
    @latest_measurement = @client_measurements.first
    if @latest_measurement&.height && @latest_measurement&.weight
      height_m = @latest_measurement.height.to_f / 100 # converter cm para metros
      @current_imc = (@latest_measurement.weight.to_f / (height_m ** 2)).round(1)
      @imc_classification = classify_imc(@current_imc)
    end
    
    # Dados para gráficos (últimas 10 medições para comparação)
    @measurements_chart_data = prepare_measurements_chart_data
    @skinfolds_chart_data = prepare_skinfolds_chart_data
  end

  def destroy
    @client.destroy
    flash[:danger] = "Cliente deletado com sucesso"
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
      flash[:danger] = "Você não possui acesso a esse dado"
      redirect_to home_path
    end
  end

  def classify_imc(imc)
    case imc
    when 0...18.5
      { category: "Abaixo do peso", color: "text-blue-600" }
    when 18.5...25
      { category: "Peso normal", color: "text-green-600" }
    when 25...30
      { category: "Sobrepeso", color: "text-yellow-600" }
    when 30...35
      { category: "Obesidade grau I", color: "text-orange-600" }
    when 35...40
      { category: "Obesidade grau II", color: "text-red-600" }
    else
      { category: "Obesidade grau III", color: "text-red-800" }
    end
  end

  def prepare_measurements_chart_data
    return { labels: [], weight: [], chest: [], waist: [] } if @client_measurements.empty?
    
    measurements_data = @client_measurements.reverse
    {
      labels: measurements_data.map { |m| m.created_at&.strftime("%d/%m") || m.created_at.strftime("%d/%m") },
      weight: measurements_data.map { |m| m.weight.to_f },
      chest: measurements_data.map { |m| m.chest.to_f },
      waist: measurements_data.map { |m| m.waist.to_f }
    }
  end

  def prepare_skinfolds_chart_data
    return { labels: [], tricep: [], subscapular: [], suprailiac: [], sum: [] } if @client_skinfolds.empty?
    
    skinfolds_data = @client_skinfolds.reverse
    {
      labels: skinfolds_data.map { |s| s.created_at&.strftime("%d/%m") || s.created_at.strftime("%d/%m") },
      tricep: skinfolds_data.map { |s| s.tricep.to_f },
      subscapular: skinfolds_data.map { |s| s.subscapular.to_f },
      suprailiac: skinfolds_data.map { |s| s.suprailiac.to_f },
      sum: skinfolds_data.map { |s| 
        tricep = s.tricep.to_f || 0
        subscapular = s.subscapular.to_f || 0
        suprailiac = s.suprailiac.to_f || 0
        tricep + subscapular + suprailiac
      }
    }
  end
end
