defmodule Haystack.Query.Expression.Match do
  @moduledoc """
  A module to define "match" expressions.
  """

  alias Haystack.Query
  alias Haystack.Storage
  alias Haystack.Index.Attr.{Docs, Meta}

  @behaviour Query.Expression

  # Behaviour: Query.Expression

  @impl Query.Expression
  def evaluate(index, %Query.Expression{k: :match} = exp) do
    with {:ok, refs} <- refs(index, exp) do
      Enum.map(refs, fn ref ->
        key = Meta.key(ref: ref, field: exp.field, term: exp.term)

        %{tf: tf, positions: positions} = Storage.fetch!(index.storage, key)

        %{
          ref: ref,
          field: exp.field,
          positions: positions,
          score: tf,
          term: exp.term
        }
      end)
    end
  end

  # Private

  defp refs(%{storage: storage}, exp) do
    case Storage.fetch(storage, Docs.key(field: exp.field, term: exp.term)) do
      {:ok, results} -> {:ok, results}
      {:error, _} -> []
    end
  end
end
