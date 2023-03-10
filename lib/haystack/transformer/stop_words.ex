defmodule Haystack.Transformer.StopWords do
  @moduledoc """
  A transformer for removing stop words.
  """

  @behaviour Haystack.Transformer

  @words Application.app_dir(:haystack, "priv/stop_words.txt")
         |> File.read!()
         |> String.trim()
         |> String.split("\n")

  @doc """
  Remove stop words from a list of tokens.

  ## Examples

    iex> tokens = Tokenizer.tokenize("and elixir")
    iex> tokens = Transformer.StopWords.transform(tokens)
    iex> Enum.map(tokens, & &1.v)
    ~w{elixir}

  """
  @impl true
  def transform(tokens) do
    Enum.reject(tokens, &Enum.member?(@words, &1.v))
  end
end
