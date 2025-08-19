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

  def search(term)
    ClientsQuery.new(@user.clients).search(term).all
  end
  
  def filter(filter_type)
    ClientsQuery.new(@user.clients).filter(filter_type).all
  end
  
  def search_and_filter(search_term, filter_type)
    ClientsQuery.new(@user.clients).search(search_term).filter(filter_type).all
  end
  
  def with_includes
    @user.clients.includes(:measurements, :payments, :skinfolds, :plan)
  end
  
  def paginated(page: 1, per_page: 20)
    @user.clients.paginate(page: page, per_page: per_page)
  end
  
  def recent
    @user.clients.order(registration_date: :desc)
  end
  
  def statistics
    ClientStatisticsService.new(@user).call
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