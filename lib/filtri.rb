require 'docile'
require 'pp'
require 'to_regexp'
require 'str2hash'

# Filtri DSL
# @author karl l <karl@ninjacontrol.com>
class Filtri

  # The rules
  attr_reader :rules
  # The meta rules
  attr_reader :meta_rules

  # @private
  RULES = [:rule, :meta]



  def initialize
    @rules      = []
    @meta_rules = []
    @passes     = 1
    @meta_applied = false
  end

  # Add a filtering rule
  # @param [Hash{Regexp => String},Hash{String => String}] rule_hash
  def rule(rule_hash)
    add_rule(@rules, rule_hash)
  end

  # Add a meta rule
  # @param [Hash{Regexp=>String}] rule_hash
  def meta(rule_hash)
    add_rule(@meta_rules, rule_hash)
  end

  # Add a rule to the current rule-set
  # @param [Array<Hash{Regexp => String},Hash{String => String}>] rule_set
  # @param [Hash{Regexp => String},Hash{String => String}] rule_hash
  # @private
  def add_rule(rule_set, rule_hash)

    rule_hash.each_key do |k|
      rule_set << { from: k, to: rule_hash[k] }
    end

  end

  # @param [Regexp, String] val
  # @param [Hash{Regexp => String},Hash{String => String}] rule
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
  # @param [Hash{Regexp => String},Hash{String => String}] in_hash
  # @param [Hash{Regexp => String},Hash{String => String}] rules
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
        unless @meta_applied
          @rules = rewrite(@rules, @meta_rules)
          @meta_applied = true
        end
      end

      @rules.each do |rule|
        in_str = in_str.gsub(rule[:from], rule[:to])
      end

    end
    in_str
  end

  # The input string is expected to contain rules and comments, one per line,
  # separated by a line break.
  # The expected format of a line is "{operation} <space> {argument} <eol>".
  # Empty lines and lines starting with a '#' are ignored. Whitespace at the beginning of a line
  # is trimmed.
  #
  # @param [String] rule_str
  # @raise [FiltriInitError] if an error occurs when initialising the rules from the provided strings
  def add_rule_str(rule_str)

    rule_str.strip.lines do |l|

      op_str = l.strip.partition " "
      if op_str[0].length > 0
        op     = op_str[0]
        op_arg = op_str[2]

        if Filtri::RULES.include? op.to_sym
          # parse arg string
          begin
            arg_hash = op_arg.to_h
          rescue Parslet::ParseFailed => err
            raise FiltriInitError, "Invalid rule format: '#{op_arg}' (#{err.message})"
          end
          # add rule
          self.send(op.to_sym,arg_hash)
        else
          raise FiltriInitError, "Unknown rule: #{op}" unless op == "#"
        end

      end
    end


  end


  # Factory, init with rule-set from a string
  #
  # The input string is expected to contain rules and comments, one per line,
  # separated by a line break.
  # The expected format of a line is '{operation} <space> {argument} <eol>'.
  # Empty lines and lines starting with a '#' are ignored. Whitespace at the beginning of a line
  # is trimmed.
  #
  # @param [String] rule_str
  # @return [Filtri] A new Filtri object with the rules parsed from the provided string(s).
  # @raise [FiltriInitError] if an error occurs when initialising the rules from the provided strings
  def self.from_str(rule_str)

    inst = Filtri.new
    inst.add_rule_str rule_str
    inst

  end

  # Load rules from a file
  # @param [String] file_name
  # @raise [IOError,SystemCallError] If an error occurs when opening the file
  # @raise [FiltriInitError] If an error occurs when parsing the rules in the file
  def load(file_name)

    data = IO.read(file_name)
    add_rule_str(data)

  end

  # Factory, Init by loading rules from a file
  # @param [String] file_name
  # @return [Filtri] A new Filtri object with the rules contained in the file
  # @raise [IOError,SystemCallError] If an error occurs when opening the file
  # @raise [FiltriInitError] If an error occurs when parsing the rules in the file
  def self.load(file_name)

    data = IO.read(file_name)
    Filtri.from_str(data)

  end


  def self.valid_rules
    Filtri::RULES
  end

end

class FiltriInitError < StandardError
  def initialize(msg)
    super(msg)
    @msg = msg
  end
end


# Create a Filtri object containing a set of rules
#
# @example
#
#   f = filtri do
#       rule "foo" => "bar"
#       rule "baz" => "bug"
#   end
#
# @return [Filtri] A new Filtri object containing the provided rules
def filtri(&block)
  Docile.dsl_eval(Filtri.new, &block)
end

