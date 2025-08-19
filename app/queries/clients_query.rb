class ClientsQuery
  attr_reader :relation

  def initialize(relation = Client.all)
    @relation = relation
  end

  def search(term)
    return self unless term.present?
    
    search_term = "%#{term.downcase}%"
    @relation = @relation.where(
      "LOWER(clients.name) LIKE :term OR LOWER(clients.cellphone) LIKE :term OR LOWER(clients.address) LIKE :term",
      term: search_term
    )
    self
  end

  def overdue
    @relation = @relation
      .joins(:payments)
      .where("payments.payment_date + INTERVAL '1 month' <= ?", Date.current)
      .group("clients.id")
      .having("MAX(payments.payment_date) = (SELECT MAX(p2.payment_date) FROM payments p2 WHERE p2.client_id = clients.id)")
    self
  end

  def by_user(user)
    @relation = @relation.where(user: user)
    self
  end

  def ordered
    @relation = @relation.order(:name)
    self
  end

  def paginated(page:, per_page: 10)
    @relation = @relation.paginate(page: page, per_page: per_page)
    self
  end

  def results
    @relation
  end
end