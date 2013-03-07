require 'docile'
require 'pp'

class Filtri

  def initialize
    @rules = []
  end

  def rule(rule_hash)

    rule_hash.each_key do |k|

      @rules << { from:k, to:rule_hash[k] }
    end
  end

  def apply(in_str)
    @rules.each do |rule|
      in_str = in_str.gsub(rule[:from],rule[:to])
    end
    in_str
  end

end

def filtri(&block)
  Docile.dsl_eval(Filtri.new, &block)
end