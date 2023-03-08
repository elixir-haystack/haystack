defmodule Haystack.Transformer.StemmerTest do
  use ExUnit.Case, async: true

  alias Haystack.{Tokenizer, Transformer}

  doctest Transformer.Stemmer

  describe "transform/1" do
    test "should stem text" do
      tokens = Tokenizer.tokenize("transformer")
      tokens = Transformer.Stemmer.transform(tokens)

      assert ~w{transform} == Enum.map(tokens, & &1.v)
    end
  end
end
