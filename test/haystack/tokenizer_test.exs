defmodule Haystack.TokenizerTest do
  use ExUnit.Case, async: true

  alias Haystack.Tokenizer

  doctest Tokenizer

  describe "tokenize/1" do
    test "should tokenize" do
      tokens = Tokenizer.tokenize("Needle in a Haystack")

      assert ~w{needle in a haystack} == Enum.map(tokens, & &1.v)
    end

    test "should remove punctuation" do
      tokens = Tokenizer.tokenize("needle, in a haystack!")

      assert ~w{needle in a haystack} == Enum.map(tokens, & &1.v)
    end

    test "should downcase" do
      tokens = Tokenizer.tokenize("Needle in a Haystack")

      assert ~w{needle in a haystack} == Enum.map(tokens, & &1.v)
    end

    test "should handle whitespace" do
      tokens = Tokenizer.tokenize("  needle   in    a    haystack  ")

      assert ~w{needle in a haystack} == Enum.map(tokens, & &1.v)
    end

    test "should tokenize integers" do
      tokens = Tokenizer.tokenize(123)

      assert ~w{123} == Enum.map(tokens, & &1.v)
    end

    test "should extract offset" do
      tokens = Tokenizer.tokenize("Needle in a Haystack")

      assert [0, 7, 10, 12] == Enum.map(tokens, & &1.offset)
    end

    test "should extract length" do
      tokens = Tokenizer.tokenize("Needle in a Haystack")

      assert [6, 2, 1, 8] == Enum.map(tokens, & &1.length)
    end
  end
end
