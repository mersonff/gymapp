module PaymentTrackable
  extend ActiveSupport::Concern

  included do
    scope :with_payments, -> { joins(:payments) }
    scope :overdue, -> {
      joins(:payments)
        .where("payments.payment_date < ?", Date.current)
        .distinct
    }
    scope :current, -> {
      joins(:payments)
        .where("payments.payment_date >= ?", Date.current)
        .distinct
    }
  end

  def last_payment
    payments.order(payment_date: :desc).first
  end

  def next_payment_date
    last_payment&.payment_date&.+ 1.month
  end

  def overdue?
    return false if payments.empty?
    # A client is overdue if their most recent payment is overdue
    last_payment&.payment_date && last_payment.payment_date < Date.current
  end

  def current?
    return true if payments.empty?
    # A client is current if their most recent payment is not overdue
    !overdue?
  end

  def days_overdue
    return 0 unless overdue?
    overdue_payments = payments.select { |p| p.payment_date < Date.current }
    return 0 if overdue_payments.empty?
    (Date.current - overdue_payments.min_by(&:payment_date).payment_date).to_i
  end
end