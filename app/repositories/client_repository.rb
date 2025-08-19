class ClientRepository
  def initialize(user)
    @user = user
  end

  def all
    @user.clients
  end

  def find(id)
    @user.clients.find(id)
  end

  def with_latest_measurements(client, limit: 10)
    {
      payments: client.payments.order(payment_date: :desc).limit(limit),
      measurements: client.measurements.order(created_at: :desc).limit(limit),
      skinfolds: client.skinfolds.order(created_at: :desc).limit(limit)
    }
  end

  def overdue
    @user.clients.overdue
  end

  def current
    @user.clients.current
  end

  def search(term)
    ClientsQuery.new(@user.clients).search(term).results
  end

  def create(attributes)
    client = @user.clients.build(attributes)
    client.save
    client
  end

  def update(client, attributes)
    client.update(attributes)
    client
  end

  def destroy(client)
    client.destroy
  end

  private

  attr_reader :user
end