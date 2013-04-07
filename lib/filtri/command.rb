require 'optparse'
require_relative 'version'
require_relative '../filtri'

class FiltriCmd
  def self.parse_opts
    options = {}

    OptionParser.new do |o|
      o.banner = "Usage: filtri [options] [input]"
      o.separator ""
      o.separator "Options:"

      o.on("-r", "--rule STRING", "Single rule") do |rule|
        if options.include?(:rules)
          options[:rules] << rule
        else
          options[:rules] = [rule]
        end
      end

      o.on("-f", "--file RULE_FILE", "File containing rules") do |rule_files|
        if options.include?(:rule_files)
          options[:rule_files] << rule_files
        else
          options[:rule_files] = [rule_files]
        end
      end

      o.on( '-v', '--version', 'Version information' ) do
        puts "version #{Filtri::VERSION}"
        exit
      end

      o.on( '-h', '--help', 'Help' ) do
        puts o
        exit
      end



    end.parse!

    options[:input] = ARGV unless ARGV.length <= 0
    options

  end

  def self.validate_opts(opts)


    unless opts.include?(:rules) || opts.include?(:rule_files)
      puts "Error: provide a rule or a rule file."
      return false
    end

    [:rule_files, :input].each do |f|
      if opts.include?(f)
        opts[f].each do |i|
          unless File.exist?(i)
            puts "Error: file #{i} does not exist."
            return false
          end
        end
      end
    end

    true

  end

  # Apply rules to the provided input
  #
  # @param [Hash{Symbol => Array<String>}] rules Where :rules contain single rule strings and :rule_files contain filename(s) of the rule file(s)
  # @param [Array<String>] input Where :input contain the input file(s)
  # @return [String] The rules applied to the input
  # @raise [FiltriInitError, IOError] if an error occurs when initialising the rules from the provided strings or files
  def self.run(rules, input)
    rule_strs  = rules[:rules] || []
    rule_files = rules[:rule_files] || []
    result = []


    # Allow for shorthand format of rules

    upd_rule_strs = rule_strs.reduce([]) do |r,v|
      if v =~ /^(#{Filtri.valid_rules.join("|")})/
        r << v
      else
        r << "rule #{v}"
      end
    end
    f = Filtri.new
    if upd_rule_strs.length > 0
      f.add_rule_str(upd_rule_strs.join("\n"))
    end

    rule_files.each do |rf|
      f.load rf
    end

    ARGV.replace(input || [])
    result << f.apply(ARGF.read)

    result.join("")
  end

end