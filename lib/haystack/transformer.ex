defmodule Haystack.Transformer do
  @moduledoc """
  A module for transforming tokens.

  This module includes a transform/1 callback behaviour for implementing stages
  of a transformation pipeline. The default pipeline transformers includes
  stages for stemming and removing stop words.
  """

  alias Haystack.Tokenizer.Token
  alias Haystack.Transformer

  @default [
    Transformer.Stemmer,
    Transformer.StopWords
  ]

  # Behaviour

  @doc """
  Apply a transformation on a list of tokens.
  """
  @callback transform(list(Token.t())) :: list(Token.t())

  # Public

  @doc """
  Return the list of default transformers.

  ## Examples

      iex> Transformer.default()
      [Transformer.Stemmer, Transformer.StopWords]

  """
  @spec default :: list(module)
  def default, do: @default

  @doc """
  Apply a pipeline of transformers to a list of tokens.

  ## Examples

      iex> tokens = Tokenizer.tokenize("Needle in a Haystack")
      iex> tokens = Transformer.pipeline(tokens, Transformer.default())
      iex> Enum.map(tokens, & &1.v)
      ~w{needl haystack}

  """
  @spec pipeline(list(Token.t()), list(module)) :: list(Token.t())
  def pipeline(tokens, transformers) do
    Enum.reduce(transformers, tokens, fn transformer, tokens ->
      transformer.transform(tokens)
    end)
  end
end
