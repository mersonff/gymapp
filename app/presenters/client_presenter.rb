class ClientPresenter
  delegate :name, :birthdate, :address, :cellphone, :gender, :payments, :measurements, :skinfolds, :plan, to: :client
  delegate_missing_to :client

  def initialize(client)
    @client = client
  end

  # Age calculation
  def age
    return nil if birthdate.blank?

    ((Date.current - birthdate) / 365.25).floor
  end

  # Phone formatting
  def formatted_phone
    return cellphone if cellphone.blank?

    # Format: (99) 99999-9999
    phone_digits = cellphone.gsub(/\D/, '')
    return cellphone if phone_digits.length != 11

    phone_digits.gsub(/(\d{2})(\d{5})(\d{4})/, '(\1) \2-\3')
  end

  # Plan methods
  def plan_name
    plan&.description || 'Sem plano'
  end

  def plan_price
    return 'N/A' unless plan&.value

    "R$ #{format('%.2f', plan.value.to_f)}".tr('.', ',')
  end

  # Registration date
  def registration_date
    return nil unless client.registration_date

    client.registration_date.strftime('%d/%m/%Y')
  end

  # Status methods
  def status
    client.current? ? 'Em dia' : 'Inadimplente'
  end

  def status_color
    client.current? ? 'text-green-600 bg-green-50' : 'text-red-600 bg-red-50'
  end

  # Measurement methods
  def latest_measurement
    measurements.order(created_at: :desc).first
  end

  def latest_weight
    measurement = latest_measurement
    return 'N/A' unless measurement&.weight

    "#{measurement.weight.to_i} kg"
  end

  def latest_height
    measurement = latest_measurement
    return 'N/A' unless measurement&.height

    "#{measurement.height.to_f.round(0)} cm"
  end

  def bmi
    measurement = latest_measurement
    return 'N/A' unless measurement&.height && measurement.weight

    height_m = measurement.height.to_f / 100
    bmi_value = measurement.weight.to_f / (height_m**2)
    format('%.1f', bmi_value)
  end

  # Skinfold methods
  def latest_body_fat
    skinfold = skinfolds.order(created_at: :desc).first
    return 'N/A' unless skinfold

    body_fat = BodyFatCalculatorService.new(client).calculate_for_skinfold(skinfold)
    return 'N/A' unless body_fat

    "#{body_fat}%"
  end

  # Payment methods
  def payment_count
    payments.count
  end

  def next_payment_date
    last_payment = payments.order(payment_date: :desc).first
    return 'N/A' unless last_payment

    future_payments = payments.where('payment_date > ?', Date.current)
    next_payment = future_payments.order(payment_date: :asc).first

    if next_payment
      next_payment.payment_date.strftime('%d/%m/%Y')
    else
      'N/A'
    end
  end

  # Gender display
  def gender_display
    case gender
    when 'M'
      'Masculino'
    when 'F'
      'Feminino'
    when 'O'
      'Outro'
    else
      gender
    end
  end

  private

  attr_reader :client
end
