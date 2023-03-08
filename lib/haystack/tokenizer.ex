defmodule Haystack.Tokenizer do
  @moduledoc """
  A module for tokenizing values.
  """

  alias Haystack.Tokenizer.Token

  @default ~r/([[:alnum:]]+)/
  @full ~r/(.+)/

  @doc """
  Return the seperator
  """
  @spec separator(atom) :: Regex.t()
  def separator(:default), do: @default
  def separator(:full), do: @full

  @doc """
  Tokenize a value.

  ## Examples

    iex> Tokenizer.tokenize("Hello, world")

  """
  @spec tokenize(term) :: list(Token.t())
  def tokenize(v), do: tokenize(v, separator(:default))

  @doc """
  Tokenize a value with a given separator.

  ## Examples

    iex> Tokenizer.tokenize("Hello, world", Tokenizer.separator(:default))

  """
  @spec tokenize(term, Regex.t()) :: list(Token.t())
  def tokenize(v, r) when is_integer(v),
    do: v |> to_string() |> tokenize(r)

  def tokenize(v, r) when is_binary(v) do
    v = String.downcase(v)

    [words(v, r), positions(v, r)]
    |> Enum.zip()
    |> Enum.map(fn {v, {s, l}} -> Token.new(v, start: s, length: l) end)
  end

  # Private

  defp words(v, r),
    do: Regex.scan(r, v, capture: :first) |> List.flatten()

  defp positions(v, r),
    do: Regex.scan(r, v, capture: :first, return: :index) |> List.flatten()
end
