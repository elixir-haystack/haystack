defmodule Haystack.Transformer do
  @moduledoc """
  A behaviour for transforming tokens.
  """

  alias __MODULE__
  alias Haystack.Tokenizer.Token

  @default [
    Transformer.Stemmer,
    Transformer.StopWords
  ]

  @doc """
  Apply a transformation on a list of tokens.
  """
  @callback transform(list(Token.t())) :: list(Token.t())

  @doc """
  Return the list of default transformers.

  ## Examples

    iex> Transformer.default()

  """
  @spec default :: list(module)
  def default, do: @default

  @doc """
  Apply a pipeline of transformers to a list of tokens.

  ## Examples

    iex> tokens = Tokenizer.tokenize("once upon a time")
    iex> Transformer.pipeline(tokens, Transformer.default())

  """
  @spec pipeline(list(Token.t()), list(module)) :: list(Token.t())
  def pipeline(tokens, transformers) do
    Enum.reduce(transformers, tokens, fn transformer, tokens ->
      transformer.transform(tokens)
    end)
  end
end
