defmodule Haystack.Transformer.StopWords do
  @moduledoc """
  A transformer for removing stop words.
  """

  @behaviour Haystack.Transformer

  @words Application.app_dir(:haystack, "priv/haystack/stop_words.txt")
         |> File.read!()
         |> String.trim()
         |> String.split("\n")

  # Haystack.Transformer

  @doc """
  Remove stop words from a list of tokens.

  ## Examples

      iex> tokens = Tokenizer.tokenize("Needle in a Haystack")
      iex> tokens = Transformer.StopWords.transform(tokens)
      iex> Enum.map(tokens, & &1.v)
      ~w{needle haystack}

  """
  @impl Haystack.Transformer
  def transform(tokens),
    do: Enum.reject(tokens, &Enum.member?(@words, &1.v))
end
