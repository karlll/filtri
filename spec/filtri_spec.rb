require "rspec"
require "filtri"

describe Filtri do

  it "applies a rule to translate a string" do

    in_str = "foo\nbaz\nbar\nfoo"
    expected = "bar\nbug\nbar\nbar"

    f = filtri do
      rule "foo" => "bar"
      rule "baz" => "bug"
    end

    result = f.apply(in_str)
    expect(result).to eq(expected)


  end

  it "applies a simple regexp rule to translate a string" do

    in_str = "foo\nbaz\nbar\nfoo"
    expected = "bar\nbug\nbar\nbar"

    f = filtri do
      rule /fo+/ => "bar"
      rule "baz" => "bug"
    end

    result = f.apply(in_str)
    expect(result).to eq(expected)


  end

  it "applies a regexp and include matches in the result" do

    in_str = "This is a test XXXXX"
    expected = "This is a passing test ! (XXXXX)"

    f = filtri do
      rule /(test)/ => 'passing \1'
      rule /(X+)/ => '! (\1)'
    end

    result = f.apply(in_str)
    expect(result).to eq(expected)


  end


  it "re-writes rules with meta-rules" do

    in_str = "foo\nbaz\nbar\nfoo"
    expected = "bar\nbug\nbar\nbar"


    f = filtri do
      meta /META/ => 'fo+'
      rule /META/ => "bar"
      rule "baz" => "bug"
    end

    result = f.apply(in_str)
    expect(result).to eq(expected)


  end

  it "re-writes regexps and plain strings with meta-rules" do

    in_str = "foobarfoobar"
    expected = "bazbagbazbag"


    f = filtri do
      meta "FB" => "foobar"
      rule /FB/ => "bazbag"
    end

    result = f.apply(in_str)
    expect(result).to eq(expected)


  end

  it "applies meta-rules on both parts of the rule" do

    in_str = "foobarfoobar"
    expected = "bazbagbazbag"


    f = filtri do
      meta "FB" => "bazbag"
      rule /foobar/ => "FB"
    end

    result = f.apply(in_str)
    expect(result).to eq(expected)

  end


  it "parses rules from strings" do



    in_str = "foobarfoobar"
    expected = "bazbagbazbag"

    strings = <<EOF

    rule /fo+bar/ => "bazbag"

EOF


    result = Filtri.from_str(strings).apply(in_str)

    expect(result).to eq(expected)

  end

  it "parses rules with comments and empty lines" do

    in_str = "foobarfoobar"
    expected = "**b**!!a!!z**b**!!a!!g**b**!!a!!z**b**!!a!!g"

    strings = %q(

    # this is a comment
    rule /fo+bar/ => "bazbag"
    rule /(a)+/ => '!!\1!!'
    rule /(b)+/ => '**\1**'

    # empty line above
    rule "text" => "some other text"



)


    f = Filtri.from_str(strings)
    result = f.apply(in_str)

    expect(result).to eq(expected)

  end

  it "raises an exception when parsing an unknown rule" do


    strings = %q(

    # Below are valid rules

    meta /XXX/ => "YYYYY"
    rule /FOO/ => "BAR"

    # Below is an unknown rule name
    stupid_rule /BAG/ => "BAR"

)
    expect { Filtri.from_str(strings) }.to raise_error(FiltriInitError)

  end

  it "raises an exception when parsing an invalid rule format" do


    strings = %q(

    # Below are valid rules

    meta /XXX/ => "YYYYY"
    rule /FOO/ => "BAR"

    # Below is an a rule w. invalid format
    rule NOT_VALID

)
    expect { Filtri.from_str(strings) }.to raise_error(FiltriInitError)

  end


  it "loads rules from external files" do

    in_str = "foobarfoobar"
    expected = "bazbagbazbag"


    content = %q(

  # this is a comment
  rule /fo+bar/ => "bazbag"

)

    IO.stub(:read).with("test.filtri").and_return content

    filename = "test.filtri"

    result = Filtri.load(filename).apply(in_str)

    expect(result).to eq(expected)


  end

  it "raises an exception when file is missing" do


    expect { Filtri.load("stupid_invalid_file") }.to raise_error(SystemCallError)

  end


end