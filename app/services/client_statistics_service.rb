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

  private

  def total_clients
    @total_clients ||= user.clients.joins(:payments).distinct.count
  end

  def current_clients
    total_clients - overdue_clients
  end

  def overdue_clients
    @overdue_clients ||= user.clients.joins(:payments)
      .where("payments.payment_date + INTERVAL '1 month' <= ?", Date.current)
      .group("clients.id")
      .having("MAX(payments.payment_date) = (SELECT MAX(p2.payment_date) FROM payments p2 WHERE p2.client_id = clients.id)")
      .count.size
  end
end