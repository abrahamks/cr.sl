# service to encode database_id to short_url and vice versa
class UrlConverterService
  ALPHABET = 'zQgbTrp8kwyvoOt2MNhSHiaf3DWGq9Js1xYElUZ6RI0VPCu5LB4KXAmcdj7enF'.freeze
  # ALPHABET consists of [a..zA..Z0..9]
  # "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".split(//).shuffle.join()
  
  def self.convert_int_to_alphabet(i)
    base = ALPHABET.length
    alphabet = ''

    return ALPHABET[0] if i == 0

    while i > 0
      alphabet << ALPHABET[i % base]
      i /= base
    end
    alphabet
  end

  def self.convert_alphabet_to_int(alphabet)
    base = ALPHABET.length
    int = 0
    alphabet.each_char.with_index do |char, exponent|
      p "#{char} - #{exponent}"
      int += ALPHABET.index(char) * (base ** exponent)
    end
    int
  end
end
