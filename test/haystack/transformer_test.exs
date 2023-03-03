defmodule Haystack.TransformerTest do
  use ExUnit.Case, async: true

  alias Haystack.{Tokenizer, Transformer}

  doctest Transformer

  describe "default/0" do
    test "should return the default transformers" do
      assert Transformer.default() == [
               Transformer.Stemmer,
               Transformer.StopWords
             ]
    end
  end

  describe "pipeline/2" do
    test "should apply a pipeline of transformations" do
      tokens = Tokenizer.tokenize("once upon a time")

      assert Transformer.pipeline(tokens, Transformer.default()) == [
               %Tokenizer.Token{v: "onc", start: 0, length: 4},
               %Tokenizer.Token{v: "time", start: 12, length: 4}
             ]
    end
  end
end
