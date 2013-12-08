require './kata'

describe CreditCardValidator do
  describe '#detect_type' do
    context 'detect all card types' do
      CreditCardValidator::CARD_TYPES.each { |card|
	eval "#{card.name.upcase} = card"
      }
      good_samples = [
	[AMEX, ['345619951443234', '378282246310005']],
	[DISCOVER, ['6011441767753254']],
	[MASTER_CARD,
	  ['5105105105105100', '5292228741833761', '5353484808994550',
	  '5407295136975467', '5526986578615266']],
	[VISA, ['4111111111111111', '4024007193564']]
      ]

      good_samples.each { |type, cards|
	cards.each { |card_no|
	  it "detects `#{type}' for `#{card_no}'" do
	    CreditCardValidator.detect_type(card_no).should == type.name
	  end
	}
      }
    end

    it "detects other card types as unknown" do
      CreditCardValidator.detect_type('3096404751923148').should == :unknown
    end

    it "detects shorter card number length as unknown" do
      CreditCardValidator.detect_type('411111111111111').should == :unknown
    end

    it "detects longer card number length as unknown" do
      CreditCardValidator.detect_type('41111111111111122').should == :unknown
    end
  end

  describe '#calc_checksum' do
    it "calculates 70 for `4408 0412 3456 7893'" do
      CreditCardValidator.calc_checksum('4408041234567893').should == 70
    end

    it "calculates 69 for `4417 1234 5678 9112'" do
      CreditCardValidator.calc_checksum('4417123456789112').should == 69
    end
  end

  describe '#valid_checksum?' do
    it 'returns true for a valid card number' do
      CreditCardValidator.valid_checksum?('4111111111111111').should == true
    end

    it 'returns false for an invalid card number' do
      CreditCardValidator.valid_checksum?('41111111111111111').should == false
    end
  end
end

describe CreditCardFormatter do
  describe '#strip_space' do
    it 'strips whitespace' do
      card_no = "		4408  0412   3456 7893 \n"
      CreditCardFormatter.strip_space(card_no).should == '4408041234567893'
    end
  end

  describe '#pretty_sprint' do
    before :all do
      @data = { '4111111111111111' => 'VISA: 4111111111111111       (valid)',
	'4111111111111' => 'VISA: 4111111111111          (invalid)',
	'4012888888881881' => 'VISA: 4012888888881881       (valid)',
	'378282246310005' => 'AMEX: 378282246310005        (valid)',
	'6011111111111117' => 'Discover: 6011111111111117   (valid)',
	'5105105105105100' => 'MasterCard: 5105105105105100 (valid)',
	'5105105105105106' => 'MasterCard: 5105105105105106 (invalid)',
	'9111111111111111' => 'Unknown: 9111111111111111    (invalid)' }
    end

    it 'prints card stats' do
      @data.each { |card_no, result|
	CreditCardFormatter.pretty_sprint(card_no).should == result
      }
    end
  end

  describe '#printable_type' do
    it 'returns well known card type (AMEX)' do
      CreditCardFormatter.printable_type(:amex).should == 'AMEX'
    end

    it "returns `Unknown' for a card type not in the list" do
      CreditCardFormatter.printable_type('!!!'.to_sym) == 'Unknown'
    end

    it "returns `Unknown' for :unknown type" do
      CreditCardFormatter.printable_type(:unknown) == 'Unknown'
    end
  end
end
