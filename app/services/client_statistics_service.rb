class ClientStatisticsService
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def calculate
    {
      total: total_clients,
      current: current_clients,
      overdue: overdue_clients
    }
  end
  
  alias_method :call, :calculate

  def total_clients
    @total_clients ||= user.clients.count
  end

  def current_clients
    @current_clients ||= user.clients.select { |client| client.current? }.count
  end

  def overdue_clients
    @overdue_clients ||= user.clients.select { |client| client.overdue? }.count
  end
end