defmodule Haystack.Transformer.StopWordsTest do
  use ExUnit.Case, async: true

  alias Haystack.{Tokenizer, Transformer}

  doctest Transformer.StopWords

  describe "transform/1" do
    test "should remove stop words" do
      tokens = Tokenizer.tokenize("Needle in a Haystack")
      tokens = Transformer.StopWords.transform(tokens)

      assert ~w{needle haystack} == Enum.map(tokens, & &1.v)
    end
  end
end
