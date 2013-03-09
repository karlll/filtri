require 'docile'
require 'pp'
require 'to_regexp'

class Filtri

  def initialize
    @rules = []
    @meta_rules = []
    @passes = 1
  end

  def rule(rule_hash)
    add_rule(@rules, rule_hash)
  end

  def meta(rule_hash)
    add_rule(@meta_rules, rule_hash)
  end

  def add_rule(rule_set, rule_hash)

    rule_hash.each_key do |k|
      rule_set << {from: k, to: rule_hash[k]}
    end

  end


  def do_rewite(val, rule)
    case val
      when Regexp
        val_str = PP.singleline_pp(val, "")
        val_str.gsub!(rule[:from], rule[:to])
        val_str.to_regexp
      when String
        val.gsub(rule[:from], rule[:to])
      else
        val
    end

  end

  def rewrite(in_hash, rules)
    out_hash = []
    in_hash.each do |v|
      f = v[:from]
      t = v[:to]

      rules.each do |r|
        f = do_rewite(f, r)
        t = do_rewite(t, r)
      end
      out_hash << {from: f, to: t}
    end
    # pp in_hash
    # pp out_hash
    out_hash
  end


  def apply(in_str)

    @passes.times do

      unless @meta_rules.empty?
        @rules = rewrite(@rules, @meta_rules)
      end

      @rules.each do |rule|
        in_str = in_str.gsub(rule[:from], rule[:to])
      end

    end
    in_str
  end


end

def filtri(&block)
  Docile.dsl_eval(Filtri.new, &block)
end