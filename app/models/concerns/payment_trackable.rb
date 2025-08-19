module PaymentTrackable
  extend ActiveSupport::Concern

  included do
    scope :with_payments, -> { joins(:payments) }
    scope :overdue, -> {
      joins(:payments)
        .where("payments.payment_date + INTERVAL '1 month' <= ?", Date.current)
        .group("clients.id")
        .having("MAX(payments.payment_date) = (SELECT MAX(p2.payment_date) FROM payments p2 WHERE p2.client_id = clients.id)")
    }
    scope :current, -> {
      joins(:payments)
        .where("payments.payment_date + INTERVAL '1 month' > ?", Date.current)
        .group("clients.id")
        .having("MAX(payments.payment_date) = (SELECT MAX(p2.payment_date) FROM payments p2 WHERE p2.client_id = clients.id)")
    }
  end

  def last_payment
    payments.order(payment_date: :desc).first
  end

  def next_payment_date
    last_payment&.payment_date&.+ 1.month
  end

  def overdue?
    return false unless next_payment_date
    next_payment_date < Date.current
  end

  def days_overdue
    return 0 unless overdue?
    (Date.current - next_payment_date).to_i
  end
end