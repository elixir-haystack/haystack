defmodule Haystack.Transformer.StemmerTest do
  use ExUnit.Case, async: true

  alias Haystack.{Tokenizer, Transformer}

  doctest Transformer.Stemmer
end
