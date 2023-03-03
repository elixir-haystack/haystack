defmodule Haystack.TokenizerTest do
  use ExUnit.Case, async: true

  alias Haystack.Tokenizer

  doctest Tokenizer

  describe "tokenize/1" do
    test "should tokenize" do
      assert Tokenizer.tokenize("hello world") == [
               %Tokenizer.Token{v: "hello", start: 0, length: 5},
               %Tokenizer.Token{v: "world", start: 6, length: 5}
             ]
    end

    test "should remove punctuation" do
      assert Tokenizer.tokenize("hello, world!") == [
               %Tokenizer.Token{v: "hello", start: 0, length: 5},
               %Tokenizer.Token{v: "world", start: 7, length: 5}
             ]
    end

    test "should downcase" do
      assert Tokenizer.tokenize("hElLo wOrLd") == [
               %Tokenizer.Token{v: "hello", start: 0, length: 5},
               %Tokenizer.Token{v: "world", start: 6, length: 5}
             ]
    end

    test "should handle whitespace" do
      assert Tokenizer.tokenize("  hello  world  ") == [
               %Tokenizer.Token{v: "hello", start: 2, length: 5},
               %Tokenizer.Token{v: "world", start: 9, length: 5}
             ]
    end

    test "should tokenize integers" do
      assert Tokenizer.tokenize(123) == [
               %Tokenizer.Token{v: "123", start: 0, length: 3}
             ]
    end

    test "should tokenize lists" do
      assert Tokenizer.tokenize(["hello", "world"]) == [
               %Tokenizer.Token{v: "hello", start: 0, length: 5},
               %Tokenizer.Token{v: "world", start: 0, length: 5}
             ]
    end
  end
end
