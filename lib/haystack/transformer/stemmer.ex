defmodule Haystack.Transformer.Stemmer do
  @moduledoc """
  A transformer for stemming words.
  """

  @behaviour Haystack.Transformer

  @doc """
  Apply a stemming transformation on a list of tokens.

  ## Examples

    iex> tokens = Tokenizer.tokenize("transformer")
    iex> Transformer.Stemmer.transform(tokens)
    [%Tokenizer.Token{v: "transform", start: 0, length: 11}]

  """
  @impl true
  def transform(tokens) do
    Enum.map(tokens, fn token ->
      %{token | v: Stemmer.stem(token.v)}
    end)
  end
end
