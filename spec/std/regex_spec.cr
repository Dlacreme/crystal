require "spec"

describe "Regex" do
  it "compare to other instances" do
    Regex.new("foo").should eq(Regex.new("foo"))
    Regex.new("foo").should_not eq(Regex.new("bar"))
  end

  it "does =~" do
    (/foo/ =~ "bar foo baz").should eq(4)
    $~.length.should eq(0)
  end

  it "does inspect" do
    /foo/.inspect.should eq("/foo/")
  end

  it "does to_s" do
    /foo/.to_s.should eq("/foo/")
    /foo/imx.to_s.should eq("/foo/imx")
  end

  it "doesn't crash when PCRE tries to free some memory (#771)" do
    expect_raises(ArgumentError) { Regex.new("foo)") }
  end

  it "escapes" do
    Regex.escape(" .\\+*?[^]$(){}=!<>|:-hello").should eq("\\ \\.\\\\\\+\\*\\?\\[\\^\\]\\$\\(\\)\\{\\}\\=\\!\\<\\>\\|\\:\\-hello")
  end

  it "matches ignore case" do
    ("HeLlO" =~ /hello/).should be_nil
    ("HeLlO" =~ /hello/i).should eq(0)
  end

  it "matches lines beginnings on ^ in multiline mode" do
    ("foo\nbar" =~ /^bar/).should be_nil
    ("foo\nbar" =~ /^bar/m).should eq(4)
  end

  it "matches multiline" do
    ("foo\n<bar\n>baz" =~ /<bar.*?>/).should be_nil
    ("foo\n<bar\n>baz" =~ /<bar.*?>/m).should eq(4)
  end

  it "matches with =~ and captures" do
    ("fooba" =~ /f(o+)(bar?)/).should eq(0)
    $~.length.should eq(2)
    $1.should eq("oo")
    $2.should eq("ba")
  end

  it "matches with =~ and gets utf-8 codepoint index" do
    index = "こんに" =~ /ん/
    index.should eq(1)
  end

  it "matches with === and captures" do
    "foo" =~ /foo/
    (/f(o+)(bar?)/ === "fooba").should be_true
    $~.length.should eq(2)
    $1.should eq("oo")
    $2.should eq("ba")
  end

  describe "name_table" do
    it "is a map of capture group number to name" do
      table = (/(?<date> (?<year>(\d\d)?\d\d) - (?<month>\d\d) - (?<day>\d\d) )/x).name_table
      table[1].should eq("date")
      table[2].should eq("year")
      table[3]?.should be_nil
      table[4].should eq("month")
      table[5].should eq("day")
    end
  end

  it "raises exception with invalid regex" do
    expect_raises(ArgumentError) { Regex.new("+") }
  end

  it "raises if outside match range with []" do
    "foo" =~ /foo/
    expect_raises(IndexError) { $1 }
  end
end
