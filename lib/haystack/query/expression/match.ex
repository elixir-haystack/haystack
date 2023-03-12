defmodule Haystack.Query.Expression.Match do
  @moduledoc """
  A module to define "match" expressions.
  """

  alias Haystack.Query
  alias Haystack.Storage
  alias Haystack.Store.Attr.{Docs, Meta}

  @behaviour Query.Expression

  @impl true
  def evaluate(%{index: index}, %Query.Expression{key: :match} = exp) do
    with {:ok, {idf, refs}} <- refs(index, exp) do
      Enum.map(refs, fn ref ->
        key = Meta.key(ref: ref, field: exp.field, term: exp.term)

        %{tf: tf, positions: positions} = Storage.fetch!(index.storage, key)

        %{ref: ref, field: exp.field, positions: positions, score: idf * tf}
      end)
    end
  end

  defp refs(%{storage: storage}, exp) do
    case Storage.fetch(storage, Docs.key(field: exp.field, term: exp.term)) do
      {:ok, results} -> {:ok, results}
      {:error, _} -> []
    end
  end
end
