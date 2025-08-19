class ClientPresenter
  delegate :name, :birthdate, :address, :cellphone, :gender, :payments, to: :client

  def initialize(client)
    @client = client
  end

  def payment_status
    overdue? ? :overdue : :current
  end

  def payment_status_text
    overdue? ? "Inadimplente" : "Em dia"
  end

  def payment_status_color
    overdue? ? "red" : "green"
  end

  def days_overdue
    return 0 unless overdue?
    
    (Date.current - next_payment_date).to_i
  end

  def days_overdue_text
    return "Em dia" unless overdue?
    
    days = days_overdue
    "#{days} #{'dia'.pluralize(days)} em atraso"
  end

  def next_payment_date
    return nil if last_payment.blank?
    
    last_payment.payment_date + 1.month
  end

  def next_payment_date_formatted
    return "Sem pagamentos" if next_payment_date.blank?
    
    I18n.l(next_payment_date, format: :long)
  end

  def age
    return nil if birthdate.blank?
    
    ((Time.current - birthdate.to_time) / 1.year.seconds).floor
  end

  def age_text
    return "Idade não informada" if age.blank?
    
    "#{age} anos"
  end

  def formatted_phone
    return cellphone if cellphone.blank?
    
    # Format: (99) 99999-9999
    cellphone.gsub(/\D/, '').gsub(/(\d{2})(\d{5})(\d{4})/, '(\1) \2-\3')
  end

  private

  attr_reader :client

  def overdue?
    return false if last_payment.blank?
    
    next_payment_date < Date.current
  end

  def last_payment
    @last_payment ||= payments.order(payment_date: :desc).first
  end
end