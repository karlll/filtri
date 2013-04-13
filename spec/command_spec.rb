require 'rspec'
require 'filtri/command'

describe FiltriCmd do

  describe "#parse_opts" do

    it 'parses multiple rules' do

      stub_const("ARGV",["-r", "{:foo => 'bar'}", "--rule", "{:foo2 => 'bar2'}"])
      out_opts = FiltriCmd.parse_opts
      out_opts.should eq({:rules=>["{:foo => 'bar'}", "{:foo2 => 'bar2'}"]})

    end

    it 'parses multiple rule files' do

      stub_const("ARGV",["-f", "file1", "--file", "file2"])
      out_opts = FiltriCmd.parse_opts
      out_opts.should eq({:rule_files=>["file1", "file2"]})

    end

    it 'parses multiple input files' do

      stub_const("ARGV",["-f", "file1", "input1", "input2"])
      out_opts = FiltriCmd.parse_opts
      out_opts.should eq({:rule_files=>["file1"], :input=> ["input1", "input2"]})


    end

  end

  describe "#validate_opts" do

    it 'requires a rule or a rule file' do

      stub_const("ARGV",["-f", "file1", "input1", "input2"])
      out_opts = FiltriCmd.parse_opts
      File.stub!(:exist?).and_return true
      FiltriCmd.validate_opts(out_opts).should be_true

      stub_const("ARGV",["--rule", "{:foo => 'bar'}", "input2"])
      out_opts = FiltriCmd.parse_opts
      FiltriCmd.validate_opts(out_opts).should be_true

      stub_const("ARGV",["input1", "input2"])
      out_opts = FiltriCmd.parse_opts
      $stderr.should_receive(:puts).with(/Error/i)
      FiltriCmd.validate_opts(out_opts).should be_false

    end

    it 'checks if files exist' do

      stub_const("ARGV",["-f", "existing_file", "input_file1", "input_file2"])
      out_opts = FiltriCmd.parse_opts
      File.stub!(:exist?).with("existing_file").and_return true
      File.stub!(:exist?).with("input_file1").and_return true
      File.stub!(:exist?).with("input_file2").and_return true
      FiltriCmd.validate_opts(out_opts).should be_true

      stub_const("ARGV",["-f", "existing_file", "input_file1", "bad_input_file2"])
      out_opts = FiltriCmd.parse_opts
      File.stub!(:exist?).with("existing_file").and_return true
      File.stub!(:exist?).with("input_file1").and_return true
      File.stub!(:exist?).with("bad_input_file2").and_return false
      $stderr.should_receive(:puts).with(/Error/i)
      FiltriCmd.validate_opts(out_opts).should be_false

    end


  end

  describe "#run" do

    let(:rules) { %q(

      # this is a comment
      rule /fo+bar/ => "bazbag"
      rule /go+blin/ => "NILBOG"

    ) }

    let(:input1) { %q(

      fooooooooooooooobar
      cookie
      goooooblin

    ) }

    let(:result1) { %q(

      bazbag
      cookie
      NILBOG

    ) }



    it 'reads rules from a file and applies to input file' do
      opts = {:rule_files=>["rule_file"], :input=> ["input_file"]}

      IO.stub(:read).with("rule_file").and_return rules
      ARGF.stub!(:read).and_return input1

      result = FiltriCmd.run(opts, opts[:input])
      result.should eq(result1)
    end

    it 'reads single rules applies to input file' do
      opts = {:rules=>['rule /fo+bar/ => "bazbag"','rule /go+blin/ => "NILBOG"'], :input=> ["input_file"]}

      ARGF.stub!(:read).and_return input1

      result = FiltriCmd.run(opts, opts[:input])
      result.should eq(result1)
    end

  end


end