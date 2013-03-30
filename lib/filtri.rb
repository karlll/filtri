require 'docile'
require 'pp'
require 'to_regexp'

# Filtri DSL
# @author karl l <karl@ninjacontrol.com>
class Filtri

  def initialize
    @rules      = []
    @meta_rules = []
    @passes     = 1
  end

  # Add a filtering rule
  # @param [Hash{Regexp=>String}] rule_hash
  def rule(rule_hash)
    add_rule(@rules, rule_hash)
  end

  # Add a meta rule
  # @param [Hash{Regexp=>String}] rule_hash
  def meta(rule_hash)
    add_rule(@meta_rules, rule_hash)
  end

  # Add a rule to the current rule set
  # @param [Array<Hash{Regexp=>String}>] rule_set
  # @param [Hash{Regexp=>String}] rule_hash
  # @private
  def add_rule(rule_set, rule_hash)

    rule_hash.each_key do |k|
      rule_set << { from: k, to: rule_hash[k] }
    end

  end

  # @param [Regexp, String] val
  # @param [Hash{Regexp => String}] rule
  # @private
  def do_rewrite(val, rule)
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

  # Rewrite a hash with a set of rules
  # @param [Hash{Pattern => String}] in_hash
  # @param [Hash{Pattern => String}] rules
  # @private
  def rewrite(in_hash, rules)
    out_hash = []
    in_hash.each do |v|
      f = v[:from]
      t = v[:to]

      rules.each do |r|
        f = do_rewrite(f, r)
        t = do_rewrite(t, r)
      end
      out_hash << { from: f, to: t }
    end
    out_hash
  end


  # Apply filtering rules to the provided string
  # @param [String] in_str
  # @return [String] the resulting string
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

  # Factory, init with ruleset from strings
  # @param [Array<String>] strings
  # @return [Filtri] A new Filtri object with the rules parsed from the provided string(s).
  def self.from_str(strings)
    strings.strip.lines do |l|
      op_str = l.strip.partition " "
      if op_str.length == 3
        op     = op_str[0]
        op_arg = op_str[2]
        puts "Got op = #{op}, arg = #{op_arg}"
      else
        unless l.strip[0] == "#" # Comment line, ignore
          puts "Unrecognized rule format : #{l}"
        end
      end
    end
  end
end

def filtri(&block)
  Docile.dsl_eval(Filtri.new, &block)
end