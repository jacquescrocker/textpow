require 'spec_helper'

describe Textpow::SyntaxNode do
  before do
    Textpow::SyntaxNode.send(:class_variable_set, "@@syntaxes", {})
  end

  describe "#load" do
    it "can load from xml .plist" do
      Textpow::SyntaxNode.load('spec/fixtures/objeck.plist').should_not == nil
    end

    it "can load from yaml .syntax" do
      Textpow::SyntaxNode.load('lib/textpow/syntax/ruby.syntax').should_not == nil
    end

    it "cannot load missing file" do
      lambda{
        Textpow::SyntaxNode.load('xxx.syntax')
      }.should raise_error
    end

    it "cannot load missing plist file" do
      lambda{
        Textpow::SyntaxNode.load('xxx.plist')
      }.should raise_error
    end
  end

  describe "#new" do
    it "loads strings from given hash" do
      syntax = Textpow::SyntaxNode.new('content' => 'CONTENT', 'name' => 'NAME')
      syntax.content.should == 'CONTENT'
      syntax.name.should == 'NAME'
    end

    it "loads regex from given hash" do
      syntax = Textpow::SyntaxNode.new('firstLineMatch' => 'aaa', 'foldingStartMarker' => 'bbb')
      syntax.firstLineMatch.inspect.should == "/aaa/"
      syntax.foldingStartMarker.inspect.should == "/bbb/"
    end

    it "raises ParsingError on invalid regex" do
      lambda{
        Textpow::SyntaxNode.new('firstLineMatch' => '$?)(:[/\]')
      }.should raise_error(Textpow::ParsingError)
    end

    it "stores itself as parent" do
      node = Textpow::SyntaxNode.new({})
      node.syntax.should == node
    end

    it "stores given parent" do
      node = Textpow::SyntaxNode.new({}, 1)
      node.syntax.should == 1
    end

    it "stores itself in global namespace under scopeName" do
      node = Textpow::SyntaxNode.new("scopeName" => 'xxx')
      node.syntaxes['xxx'].should == node
      Textpow::SyntaxNode.new({}).syntaxes['xxx'].should == node
    end

    it "stores itself in scoped global namespace under scopeName" do
      node = Textpow::SyntaxNode.new({"scopeName" => 'xxx'}, nil, 'foo')
      node.syntaxes['xxx'].should == node
      Textpow::SyntaxNode.new({},nil,'foo').syntaxes['xxx'].should == node
      Textpow::SyntaxNode.new({}).syntaxes['xxx'].should == nil
    end
  end
end