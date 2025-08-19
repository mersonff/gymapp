class BodyFatCalculatorService
  MALE_COEFFICIENTS = {
    density_base: 1.112,
    total_coefficient: -0.00043499,
    total_squared_coefficient: 0.00000055,
    age_coefficient: -0.00028826
  }.freeze

  FEMALE_COEFFICIENTS = {
    density_base: 1.097,
    total_coefficient: -0.00046971,
    total_squared_coefficient: 0.00000056,
    age_coefficient: -0.00012828
  }.freeze

  def initialize(client)
    @client = client
  end

  def calculate_for_skinfold(skinfold)
    @skinfold = skinfold
    return nil unless valid_skinfold_data?
    body_fat_percentage.round(1)
  end

  private

  attr_reader :client, :skinfold

  def body_fat_percentage
    (495 / body_density) - 450
  end

  def body_density
    coefficients = male? ? MALE_COEFFICIENTS : FEMALE_COEFFICIENTS
    
    coefficients[:density_base] +
      (coefficients[:total_coefficient] * total_skinfolds) +
      (coefficients[:total_squared_coefficient] * total_skinfolds**2) +
      (coefficients[:age_coefficient] * age)
  end

  def total_skinfolds
    @total_skinfolds ||= if male?
      # Jackson-Pollock 3-site formula for men: chest, abdomen, thigh
      [skinfold.chest, skinfold.abdominal, skinfold.thigh].compact.sum
    else
      # Jackson-Pollock 3-site formula for women: tricep, suprailiac, thigh
      [skinfold.tricep, skinfold.suprailiac, skinfold.thigh].compact.sum
    end
  end

  def age
    @age ||= ((Time.current - client.birthdate.to_time) / 1.year.seconds).floor
  end

  def male?
    client.gender == "M"
  end
  
  def valid_skinfold_data?
    return false unless client.gender.in?(%w[M F])
    
    if male?
      # For males, need chest, abdomen, and thigh
      [skinfold.chest, skinfold.abdominal, skinfold.thigh].all? { |v| v&.positive? }
    else
      # For females, need tricep, suprailiac, and thigh
      [skinfold.tricep, skinfold.suprailiac, skinfold.thigh].all? { |v| v&.positive? }
    end
  end
end