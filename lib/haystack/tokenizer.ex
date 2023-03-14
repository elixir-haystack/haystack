defmodule Haystack.Tokenizer do
  @moduledoc """
  A module for tokenizing values.

  This module provides utilities for tokenizing values. The default tokenizer
  removes anything but alphanumeric characters and extracts the positions of
  words using a start offset and length.

  There's also a `:full` tokenizer that can be used when the full value should
  be treated as a single token. For example, a serial code.
  """

  alias Haystack.Tokenizer.Token

  @default ~r/([[:alnum:]]+)/
  @full ~r/(.+)/

  # Public

  @doc """
  Return the seperator

  ## Examples

      iex> Tokenizer.separator(:default)
      ~r/([[:alnum:]]+)/

      iex> Tokenizer.separator(:full)
      ~r/(.+)/

  """
  @spec separator(atom) :: Regex.t()
  def separator(:default), do: @default
  def separator(:full), do: @full

  @doc """
  Tokenize a value.

  ## Examples

      iex> tokens = Tokenizer.tokenize("Needle in a Haystack")
      iex> Enum.map(tokens, & &1.v)
      ~w{needle in a haystack}

  """
  @spec tokenize(term) :: list(Token.t())
  def tokenize(v), do: tokenize(v, separator(:default))

  @doc """
  Tokenize a value with a given separator.

  ## Examples

      iex> tokens = Tokenizer.tokenize("Needle in a Haystack", Tokenizer.separator(:default))
      iex> Enum.map(tokens, & &1.v)
      ~w{needle in a haystack}

  """
  @spec tokenize(term, Regex.t()) :: list(Token.t())
  def tokenize(v, r) when is_integer(v),
    do: v |> to_string() |> tokenize(r)

  def tokenize(v, r) when is_binary(v) do
    v = String.downcase(v)

    [words(v, r), positions(v, r)]
    |> Enum.zip()
    |> Enum.map(fn {v, {o, l}} -> Token.new(v, offset: o, length: l) end)
  end

  # Private

  # Extract the tokenized words from the value.
  defp words(v, r),
    do: Regex.scan(r, v, capture: :first) |> List.flatten()

  # Extract the positions from the value.
  defp positions(v, r),
    do: Regex.scan(r, v, capture: :first, return: :index) |> List.flatten()
end
