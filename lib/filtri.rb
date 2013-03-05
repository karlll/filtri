require 'docile'
require 'pp'

class Filtri

  def initialize
    @str = ""
  end

  def rule(rule_hash)

    rule_hash.each_key do |k|

      @str = @str + "#{k} to #{rule_hash[k]}\n"
    end
  end

  def apply
    @str
  end

end

