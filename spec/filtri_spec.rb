require "rspec"
require "filtri"

describe Filtri do

  it "should apply a rule to translate a string" do

    in_str = "foo\nbaz\nbar\nfoo"
    expected = "bar\nbug\nbar\nbar"

    f = filtri do
      rule "foo" => "bar"
      rule "baz" => "bug"
    end

    result = f.apply(in_str)
    expect(result).to eq(expected)


  end

  it "should apply a simple regexp rule to translate a string" do

    in_str = "foo\nbaz\nbar\nfoo"
    expected = "bar\nbug\nbar\nbar"

    f = filtri do
      rule /fo+/ => "bar"
      rule "baz" => "bug"
    end

    result = f.apply(in_str)
    expect(result).to eq(expected)


  end

  it "should apply a regexp and include matches in the result" do

    in_str = "This is a test XXXXX"
    expected = "This is a passing test ! (XXXXX)"

    f = filtri do
      rule /(test)/ => 'passing \1'
      rule /(X+)/ => '! (\1)'
    end

    result = f.apply(in_str)
    expect(result).to eq(expected)


  end


  it "should re-write rules with meta-rules" do

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

  it "should handle regexp as well as plain strings when applying meta-rules" do

    in_str = "foobarfoobar"
    expected = "bazbagbazbag"


    f = filtri do
      meta "FB" => "foobar"
      rule /FB/ => "bazbag"
    end

    result = f.apply(in_str)
    expect(result).to eq(expected)


  end

  it "should handle apply meta rules to the 'from' and 'to' part of the rule hash" do

    in_str = "foobarfoobar"
    expected = "bazbagbazbag"


    f = filtri do
      meta "FB" => "bazbag"
      rule /foobar/ => "FB"
    end

    result = f.apply(in_str)
    expect(result).to eq(expected)

  end


  it "should parse rules from strings" do

    pending("parsing rules from string is not implemented")

    in_str = "foobarfoobar"
    expected = "bazbagbazbag"

    strings = <<EOF

  # this is a comment
  rule /fo+bar/ => "bazbag"

EOF


    result = Filtri.from_str(strings).apply(in_str)

    expect(result).to eq(expected)

  end

  it "should load rules from external files" do

    pending("loading rules from files is not implemented")
    in_str = "foobarfoobar"
    expected = "bazbagbazbag"


    f = <<EOF

  # this is a comment
  rule /fo+bar/ => "bazbag"

EOF

    filename = "test.filtri"

    result = Filtri.load(filename).apply(in_str)

    expect(result).to eq(expected)


  end


end