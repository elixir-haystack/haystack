defmodule Haystack.Transformer.StemmerTest do
  use ExUnit.Case, async: true

  alias Haystack.{Tokenizer, Transformer}

  doctest Transformer.Stemmer

  describe "transform/1" do
    test "should stem text" do
      tokens = Tokenizer.tokenize("Needle in a Haystack")
      tokens = Transformer.Stemmer.transform(tokens)

      assert ~w{needl in a haystack} == Enum.map(tokens, & &1.v)
    end
  end
end
