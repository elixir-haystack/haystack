defmodule Haystack.Transformer.StopWordsTest do
  use ExUnit.Case, async: true

  alias Haystack.{Tokenizer, Transformer}

  doctest Transformer.StopWords
end
