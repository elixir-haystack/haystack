defmodule Haystack.Transformer.StopWordsTest do
  use ExUnit.Case, async: true

  alias Haystack.{Tokenizer, Transformer}

  doctest Transformer.StopWords

  describe "transform/1" do
    test "should remove stop words" do
      tokens = Tokenizer.tokenize("and then elixir")
      tokens = Transformer.StopWords.transform(tokens)

      assert ~w{elixir} == Enum.map(tokens, & &1.v)
    end
  end
end
