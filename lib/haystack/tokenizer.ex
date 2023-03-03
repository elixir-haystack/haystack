defmodule Haystack.Tokenizer do
  @moduledoc """
  A module for tokenizing values.
  """

  alias Haystack.Tokenizer.Token

  @doc """
  Tokenize a value.

  ## Examples

    iex> Tokenizer.tokenize("Hello, world")
    [
      %Tokenizer.Token{v: "hello", start: 0, length: 5},
      %Tokenizer.Token{v: "world", start: 7, length: 5}
    ]

  """
  @spec tokenize(term) :: list(Token.t())
  def tokenize(v) when is_integer(v),
    do: v |> to_string() |> tokenize()

  def tokenize(v) when is_list(v),
    do: Enum.flat_map(v, &tokenize/1)

  def tokenize(v) when is_binary(v) do
    v = String.downcase(v)

    [words(v), positions(v)]
    |> Enum.zip()
    |> Enum.map(fn {v, {s, l}} -> Token.new(v, start: s, length: l) end)
  end

  # Private

  @r ~r/([[:alnum:]]+)/

  defp words(v),
    do: Regex.scan(@r, v, capture: :first) |> List.flatten()

  defp positions(v),
    do: Regex.scan(@r, v, capture: :first, return: :index) |> List.flatten()
end
