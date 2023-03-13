defmodule Haystack.Store.Document do
  @moduledoc """
  A module for preparing documents to be stored.
  """

  alias Haystack.{Tokenizer, Transformer}

  @type t :: %__MODULE__{
          ref: String.t(),
          fields: %{String.t() => list(Tokenizer.Token.t())}
        }

  defstruct ~w{ref fields}a

  @doc """
  Create a new document.
  """
  def new(index, params) do
    fields = [index.ref | index.fields |> Map.values()]

    {[%{v: ref}], fields} =
      params
      |> normalize()
      |> extract(fields)
      |> tokenize()
      |> transform()
      |> Enum.into(%{})
      |> Map.pop!(index.ref.key)

    struct(__MODULE__, ref: ref, fields: fields)
  end

  # Private

  # Normalize the keys of the map to strings
  defp normalize(map) when is_map(map),
    do: Enum.map(map, &normalize/1) |> Enum.into(%{})

  defp normalize({k, v}) when is_map(v),
    do: {to_string(k), v |> Enum.map(&normalize/1) |> Enum.into(%{})}

  defp normalize({k, v}),
    do: {to_string(k), v}

  #  Extract the fields from the map
  defp extract(map, fields) do
    fields
    |> Enum.map(fn field -> {get_in(map, field.path), field} end)
    |> Enum.reject(fn {v, _field} -> is_nil(v) end)
    |> Enum.map(fn {v, field} -> {field.key, {v, field}} end)
  end

  # Tokenize the values
  def tokenize(list) do
    Enum.map(list, fn {k, {v, field}} ->
      {k, {Tokenizer.tokenize(v, field.separator), field}}
    end)
  end

  # Transform the values
  def transform(list) do
    Enum.map(list, fn {k, {tokens, field}} ->
      tokens = Transformer.pipeline(tokens, field.transformers)
      counts = Enum.frequencies_by(tokens, & &1.v)
      groups = Enum.group_by(tokens, & &1.v)

      values =
        Enum.map(groups, fn {v, group} ->
          %{}
          |> Map.put(:v, v)
          |> Map.put(:positions, Enum.map(group, &{&1.start, &1.length}))
          |> Map.put(:tf, Float.round(Map.get(counts, v) / Enum.count(tokens), 2))
        end)

      {k, values}
    end)
  end
end
