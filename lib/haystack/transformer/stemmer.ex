defmodule Haystack.Transformer.Stemmer do
  @moduledoc """
  A transformer for stemming words.
  """

  @behaviour Haystack.Transformer

  # Behaviour: Haystack.Transformer

  @doc """
  Apply a stemming transformation on a list of tokens.

  ## Examples

      iex> tokens = Tokenizer.tokenize("Needle in a Haystack")
      iex> tokens = Transformer.Stemmer.transform(tokens)
      iex> Enum.map(tokens, & &1.v)
      ~w{needl in a haystack}

  """
  @impl Haystack.Transformer
  def transform(tokens) do
    Enum.map(tokens, fn token ->
      %{token | v: Stemmer.stem(token.v)}
    end)
  end
end
