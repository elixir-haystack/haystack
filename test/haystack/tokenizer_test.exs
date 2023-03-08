defmodule Haystack.TokenizerTest do
  use ExUnit.Case, async: true

  alias Haystack.Tokenizer

  doctest Tokenizer

  describe "tokenize/1" do
    test "should tokenize" do
      tokens = Tokenizer.tokenize("hello world")

      assert ~w{hello world} == Enum.map(tokens, & &1.v)
    end

    test "should remove punctuation" do
      tokens = Tokenizer.tokenize("hello, world!")

      assert ~w{hello world} == Enum.map(tokens, & &1.v)
    end

    test "should downcase" do
      tokens = Tokenizer.tokenize("hElLo wOrLd")

      assert ~w{hello world} == Enum.map(tokens, & &1.v)
    end

    test "should handle whitespace" do
      tokens = Tokenizer.tokenize("  hello  world  ")

      assert ~w{hello world} == Enum.map(tokens, & &1.v)
    end

    test "should tokenize integers" do
      tokens = Tokenizer.tokenize(123)

      assert ~w{123} == Enum.map(tokens, & &1.v)
    end

    test "should extract start positions" do
      tokens = Tokenizer.tokenize("hello world")

      assert [0, 6] == Enum.map(tokens, & &1.start)
    end

    test "should extract length" do
      tokens = Tokenizer.tokenize("hello world")

      assert [5, 5] == Enum.map(tokens, & &1.length)
    end
  end
end
