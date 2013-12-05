#!/usr/bin/ruby1.9.3

module CreditCardValidator
  Card = Struct.new(:name, :starts_with, :lengths) do
    def match? card_no
      lengths.include?(card_no.size) && card_no =~ starts_with
    end

    def to_s
      name
    end
  end

  CARDS = [Card.new('AMEX', /^3[47]/, [15]),
    Card.new('Discover', /^6011/, [16]),
    Card.new('MasterCard', /^5[1-5]/, [16]),
    Card.new('VISA', /^4/, [13, 16])]

  PRETTY_SPRINT_PART1_LENGTH = CARDS.map { |c| c.name.size }.max + 2 +
    CARDS.map { |c| c.lengths.max }.max
  PRETTY_SPRINT_FORMAT = "%-#{PRETTY_SPRINT_PART1_LENGTH}s (%s)"

  def self.calc_checksum card_no
    double, sum = true, 0
    sum += card_no[-1].to_i
    (card_no.size - 2).downto(0) { |i|
      n = card_no[i].to_i
      n *= 2 if double
      double = !double
      next sum += n if n < 10

      sum += n.to_s.chars.map(&:to_i).inject(0, :+)
    }
    sum
  end

  def self.detect_type card_no
    found = CARDS.find { |card| card.match? card_no }
    found ? found.name : 'Unknown'
  end

  def self.pretty_sprint card_no
    sprintf(PRETTY_SPRINT_FORMAT, "#{detect_type(card_no)}: #{card_no}",
      valid_checksum?(card_no) ? 'valid' : 'invalid')
  end

  def self.strip_and_sprint card_no
    pretty_sprint strip_space(card_no)
  end

  def self.strip_space card_no
    card_no.gsub /\s+/, ''
  end

  def self.valid_checksum? card_no
    calc_checksum(card_no) % 10 == 0
  end
end

if $0 == __FILE__
  $stdin.each { |line|
    puts CreditCardValidator.strip_and_sprint line
  }
end