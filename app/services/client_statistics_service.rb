class ClientStatisticsService
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def calculate
    {
      total: total_clients,
      current: current_clients,
      overdue: overdue_clients,
    }
  end

  alias call calculate

  def total_clients
    @total_clients ||= user.clients.count
  end

  def current_clients
    @current_clients ||= user.clients.count(&:current?)
  end

  def overdue_clients
    @overdue_clients ||= user.clients.count(&:overdue?)
  end
end
