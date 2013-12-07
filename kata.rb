#!/usr/bin/ruby1.9.3

module CreditCardValidator
  CardType = Struct.new(:name, :starts_with, :lengths) do
    def matches? card_no
      lengths.include?(card_no.size) && card_no =~ starts_with
    end

    def to_s
      name
    end
  end

  CARD_TYPES = [CardType.new('AMEX', /^3[47]/, [15]),
    CardType.new('Discover', /^6011/, [16]),
    CardType.new('MasterCard', /^5[1-5]/, [16]),
    CardType.new('VISA', /^4/, [13, 16])]

  def self.calc_checksum card_no
    double = false
    card_no.chars.map(&:to_i).reverse.inject(0) { |sum, n|
      n *= 2 if double
      double = !double
      next sum += n if n < 10

      sum += n.to_s.chars.map(&:to_i).inject(0, :+)
    }
  end

  def self.detect_type card_no
    found = CARD_TYPES.find { |card| card.matches? card_no }
    found ? found.name : 'Unknown'
  end

  def self.valid_checksum? card_no
    calc_checksum(card_no) % 10 == 0
  end
end

module CreditCardFormatter
  PRETTY_SPRINT_PART1_LENGTH =
    CreditCardValidator::CARD_TYPES.map { |c| c.name.size }.max + 2 +
    CreditCardValidator::CARD_TYPES.map { |c| c.lengths.max }.max
  PRETTY_SPRINT_FORMAT = "%-#{PRETTY_SPRINT_PART1_LENGTH}s (%s)"

  def self.pretty_sprint card_no
    card_no = strip_space card_no
    sprintf(PRETTY_SPRINT_FORMAT,
      "#{CreditCardValidator::detect_type(card_no)}: #{card_no}",
      CreditCardValidator.valid_checksum?(card_no) ? 'valid' : 'invalid')
  end

  def self.strip_space card_no
    card_no.gsub /\s+/, ''
  end
end

if $0 == __FILE__
  $stdin.each { |line|
    puts CreditCardFormatter.pretty_sprint line
  }
end
