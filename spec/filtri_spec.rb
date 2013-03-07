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

end