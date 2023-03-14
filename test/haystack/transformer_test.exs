defmodule Haystack.TransformerTest do
  use ExUnit.Case, async: true

  alias Haystack.{Tokenizer, Transformer}

  doctest Transformer

  describe "pipeline/2" do
    test "should apply a pipeline of transformations" do
      tokens = Tokenizer.tokenize("Needle in a Haystack")
      tokens = Transformer.pipeline(tokens, Transformer.default())

      assert ~w{needl haystack} == Enum.map(tokens, & &1.v)
    end
  end
end
