class ClientsController < ApplicationController
  before_action :set_client, only: [:edit, :update, :show, :destroy, :new_measurement, :create_measurement, :new_payment, :create_payment, :new_skinfold, :create_skinfold]
  before_action :require_user, except: [:index]
  before_action :require_same_user, only: [:edit, :update, :destroy]

  def index
    return redirect_to(login_path) unless logged_in?
    
    # Query object para busca e filtros
    query = ClientsQuery.new(current_user.clients)
    query.search(params[:search]) if params[:search].present?
    query.overdue if params[:filter] == 'overdue'
    
    @clients = query.ordered.paginated(page: params[:page]).results
    
    # Service para estatísticas
    stats = ClientStatisticsService.new(current_user).calculate
    @total_clients = stats[:total]
    @current_clients = stats[:current]
    @overdue_clients = stats[:overdue]
    
    respond_to do |format|
      format.html
      format.turbo_stream do
        # Se é uma busca/filtro, atualiza apenas a lista
        if params[:search].present? || params[:filter].present?
          render turbo_stream: turbo_stream.update("clients_content", partial: "clients_list", locals: { clients: @clients })
        else
          # Se é um redirect (após create/update), renderiza a página completa
          render :index
        end
      end
    end
  end

  def new
      @client = Client.new
      @client.measurements.build
      @client.skinfolds.build
      @client.payments.build
      
      respond_to do |format|
        format.html
        format.turbo_stream
      end
  end

  def edit
    # No edit, não construímos novos registros automaticamente
    # O formulário deve trabalhar apenas com os dados existentes
    # Se quiser adicionar novos, deve ser uma action separada
    
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def create
    @client = Client.new(client_params)
    @client.user = current_user
    
    respond_to do |format|
      if @client.save
        format.turbo_stream do
          flash[:success] = "Cliente criado com sucesso"
          redirect_to clients_path, status: :see_other
        end
        format.html do
          flash[:success] = "Cliente criado com sucesso"
          redirect_to clients_path
        end
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("new_client_form", partial: "clients/form", locals: { client: @client })
        end
        format.html do
          flash.now[:danger] = "Erro ao criar cliente: #{@client.errors.full_messages.join(', ')}"
          render :new
        end
      end
    end
  end

  def update
    respond_to do |format|
      if @client.update(client_params)
        format.turbo_stream do
          flash[:success] = "Cliente atualizado com sucesso"
          redirect_to clients_path, status: :see_other
        end
        format.html do
          flash[:success] = "Cliente atualizado com sucesso"
          redirect_to clients_path
        end
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("edit_client_form", partial: "clients/form", locals: { client: @client })
        end
        format.html do
          flash.now[:danger] = "Erro ao atualizar cliente: #{@client.errors.full_messages.join(', ')}"
          render :edit
        end
      end
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
    
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def new_measurement
    @measurement = @client.measurements.build
    
    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  def create_measurement
    @measurement = @client.measurements.build(clean_measurement_params)
    
    respond_to do |format|
      if @measurement.save
        format.turbo_stream do
          flash[:success] = "Medida adicionada com sucesso"
          redirect_to client_path(@client), status: :see_other
        end
        format.html { redirect_to client_path(@client) }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("measurement_form", partial: "clients/measurement_form", locals: { measurement: @measurement })
        end
        format.html { redirect_to client_path(@client), alert: "Erro ao criar medida" }
      end
    end
  end

  def new_payment
    @payment = @client.payments.build
    
    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  def create_payment
    @payment = @client.payments.build(payment_params)
    
    respond_to do |format|
      if @payment.save
        format.turbo_stream do
          flash[:success] = "Pagamento registrado com sucesso"
          redirect_to client_path(@client), status: :see_other
        end
        format.html { redirect_to client_path(@client) }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("payment_form", partial: "clients/payment_form", locals: { payment: @payment })
        end
        format.html { redirect_to client_path(@client), alert: "Erro ao criar pagamento" }
      end
    end
  end

  def new_skinfold
    @skinfold = @client.skinfolds.build
    
    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  def create_skinfold
    @skinfold = @client.skinfolds.build(skinfold_params)
    
    respond_to do |format|
      if @skinfold.save
        format.turbo_stream do
          flash[:success] = "Dobras cutâneas adicionadas com sucesso"
          redirect_to client_path(@client), status: :see_other
        end
        format.html { redirect_to client_path(@client) }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("skinfold_form", partial: "clients/skinfold_form", locals: { skinfold: @skinfold })
        end
        format.html { redirect_to client_path(@client), alert: "Erro ao criar dobras cutâneas" }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @client.destroy
        # Service para recalcular estatísticas
        stats = ClientStatisticsService.new(current_user).calculate
        
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove("client_#{@client.id}"),
            turbo_stream.update("flash_messages", partial: "layouts/flash", locals: { flash: { success: "Cliente deletado com sucesso" } }),
            turbo_stream.update("clients_stats", partial: "clients/stats", locals: { 
              total_clients: stats[:total],
              current_clients: stats[:current],
              overdue_clients: stats[:overdue]
            })
          ]
        end
        format.html do
          flash[:success] = "Cliente deletado com sucesso"
          redirect_to clients_path
        end
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("flash_messages", partial: "layouts/flash", locals: { flash: { danger: "Erro ao deletar cliente" } })
        end
        format.html do
          flash[:danger] = "Erro ao deletar cliente"
          redirect_to clients_path
        end
      end
    end
  end

  private

  def set_client
    if current_user
      @client = current_user.clients.find(params[:id])
    else
      @client = Client.find(params[:id])
    end
  end

  def client_params
    # Se é criação de cliente novo, permite nested attributes
    if action_name == 'create' || params[:with_measurements] == 'true'
      params.require(:client).permit(:name, :birthdate, :address, :cellphone, :gender, :plan_id,
        measurements_attributes: [ :id, :_destroy, :height, :weight, :chest, :left_arm, :right_arm, :waist, :abdomen, :hips, :left_thigh, :righ_thigh],
        skinfolds_attributes: [ :id, :_destroy, :chest, :midaxilary, :subscapular, :bicep, :tricep, :abdominal, :suprailiac, :thigh, :calf],
        payments_attributes: [ :id, :_destroy, :payment_date, :value ] )
    else
      # Para edição, apenas dados básicos do cliente
      params.require(:client).permit(:name, :birthdate, :address, :cellphone, :gender, :plan_id)
    end
  end

  def measurement_params
    params.require(:measurement).permit(:height, :weight, :chest, :left_arm, :right_arm, :waist, :abdomen, :hips, :left_thigh, :righ_thigh)
  end
  
  def clean_measurement_params
    cleaned = measurement_params.to_h
    # Convert empty strings to nil for numeric validations
    cleaned.each do |key, value|
      cleaned[key] = nil if value.blank?
    end
    cleaned
  end

  def payment_params
    params.require(:payment).permit(:payment_date, :value)
  end

  def skinfold_params
    params.require(:skinfold).permit(:chest, :midaxilary, :subscapular, :bicep, :tricep, :abdominal, :suprailiac, :thigh, :calf)
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
