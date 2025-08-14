class PagesController < ApplicationController
    before_action :require_user
    
    def home
      @clients = current_user.clients
      
      # Estatísticas de clientes
      @total_clients = @clients.joins(:payments).distinct.count
      @overdue_clients = @clients.joins(:payments)
        .where("payments.payment_date + INTERVAL '1 month' <= ?", Date.current)
        .group("clients.id")
        .having("MAX(payments.payment_date) = (SELECT MAX(p2.payment_date) FROM payments p2 WHERE p2.client_id = clients.id)")
        .count.size
      @current_clients = @total_clients - @overdue_clients
      
      # Dados financeiros
      current_month = Date.current.beginning_of_month
      current_year = Date.current.beginning_of_year
      
      @monthly_revenue = Payment.joins(client: :user)
        .where(users: { id: current_user.id })
        .where(payment_date: current_month..current_month.end_of_month)
        .sum(:value)
      
      @yearly_revenue = Payment.joins(client: :user)
        .where(users: { id: current_user.id })
        .where(payment_date: current_year..current_year.end_of_year)
        .sum(:value)
      
      # Dados para o gráfico (últimos 12 meses)
      @chart_data = (11.downto(0)).map do |months_ago|
        month_start = months_ago.months.ago.beginning_of_month
        month_end = month_start.end_of_month
        revenue = Payment.joins(client: :user)
          .where(users: { id: current_user.id })
          .where(payment_date: month_start..month_end)
          .sum(:value)
        [month_start.strftime("%b/%y"), revenue.to_f]
      end
      
      # Lista de clientes inadimplentes para exibir
      @clients_indebt = @clients.joins(:payments)
        .where("payments.payment_date + INTERVAL '1 month' <= ?", Date.current)
        .group("clients.id")
        .having("MAX(payments.payment_date) = (SELECT MAX(p2.payment_date) FROM payments p2 WHERE p2.client_id = clients.id)")
        .limit(10)
    end

    def revenue_data
      year = params[:year].present? ? params[:year].to_i : Date.current.year
      month_param = params[:month]
      month = month_param.to_s.strip
      month_int = month.match?(/^\d+$/) ? month.to_i : nil

      Rails.logger.info "[revenue_data] params: #{params.inspect} | year: #{year} | month: '#{month}' | month_int: #{month_int}"

      if month_int && month_int >= 1 && month_int <= 12
        # Filtro: ano e mês selecionados => gráfico diário do mês
        start_date = Date.new(year, month_int, 1)
        end_date = start_date.end_of_month
        chart_data = (start_date..end_date).map do |date|
          revenue = Payment.joins(client: :user)
            .where(users: { id: current_user.id })
            .where(payment_date: date.beginning_of_day..date.end_of_day)
            .sum(:value)
          [date.strftime("%d/%m"), revenue.to_f]
        end
        total_revenue = chart_data.sum { |_, value| value }
        period_type = 'daily'
      else
        # Filtro: só ano selecionado => gráfico mensal do ano
        chart_data = (1..12).map do |m|
          month_start = Date.new(year, m, 1)
          month_end = month_start.end_of_month
          revenue = Payment.joins(client: :user)
            .where(users: { id: current_user.id })
            .where(payment_date: month_start..month_end)
            .sum(:value)
          [month_start.strftime("%b/%y"), revenue.to_f]
        end
        total_revenue = chart_data.sum { |_, value| value }
        period_type = 'monthly'
      end

      render json: {
        chart_data: chart_data,
        total_revenue: total_revenue,
        period_type: period_type
      }
    end
end