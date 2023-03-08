defmodule Haystack.TransformerTest do
  use ExUnit.Case, async: true

  alias Haystack.{Tokenizer, Transformer}

  doctest Transformer

  describe "pipeline/2" do
    test "should apply a pipeline of transformations" do
      tokens = Tokenizer.tokenize("once upon a time")
      tokens = Transformer.pipeline(tokens, Transformer.default())

      assert ~w{onc time} == Enum.map(tokens, & &1.v)
    end
  end
end
