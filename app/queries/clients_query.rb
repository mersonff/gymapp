class ClientsQuery
  attr_reader :relation

  def initialize(relation = Client.all)
    @relation = relation
  end

  def search(term)
    return self unless term.present?
    
    search_term = "%#{term.downcase}%"
    
    # If the search term looks like a phone number (only digits), also search in phone numbers without formatting
    if term.match?(/^\d+$/)
      phone_search_term = "%#{term}%"
      @relation = @relation.where(
        "LOWER(clients.name) LIKE :term OR LOWER(clients.cellphone) LIKE :term OR LOWER(clients.address) LIKE :term OR REGEXP_REPLACE(clients.cellphone, '[^0-9]', '', 'g') LIKE :phone_term",
        term: search_term,
        phone_term: phone_search_term
      )
    else
      @relation = @relation.where(
        "LOWER(clients.name) LIKE :term OR LOWER(clients.cellphone) LIKE :term OR LOWER(clients.address) LIKE :term",
        term: search_term
      )
    end
    self
  end

  def overdue
    @relation = @relation
      .joins(:payments)
      .where("payments.payment_date < ?", Date.current)
      .distinct
    self
  end
  
  def filter(filter_type)
    case filter_type
    when 'overdue'
      overdue
    when 'all', '', nil
      self
    else
      self
    end
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
  
  alias_method :all, :results
end