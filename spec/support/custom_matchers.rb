module NormaliseWhitespace
    def self.perform(s)
        s.gsub(/\A\s+|\s+\Z/, "").gsub(/\s+/, " ")
    end
end

RSpec::Matchers.define :be_equal_modulo_whitespace_to do |expected|
  match do |actual|
    NormaliseWhitespace.perform(actual) == NormaliseWhitespace.perform(expected)
  end
end