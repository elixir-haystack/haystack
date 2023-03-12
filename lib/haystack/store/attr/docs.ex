defmodule Haystack.Store.Attr.Docs do
  @moduledoc """
  A module for returning a list of docs for a given field, term.
  """

  import Record

  alias Haystack.{Index, Storage, Store}
  alias Haystack.Store.Attr

  @behaviour Store.Attr

  defrecord :docs, field: nil, term: nil

  @impl true
  def key(opts) do
    docs(field: Keyword.fetch!(opts, :field), term: Keyword.fetch!(opts, :term))
  end

  @impl true
  def insert(index, %{ref: ref, fields: fields}) do
    storage =
      Enum.reduce(fields, index.storage, fn {k, terms}, storage ->
        Enum.reduce(terms, storage, fn term, storage ->
          k = key(field: k, term: term.v)
          total = Enum.count(Storage.fetch!(storage, Attr.Global.key())) + 1

          Storage.upsert(storage, k, idf(total, [ref]), fn {_, refs} ->
            idf(total, [ref | refs])
          end)
        end)
      end)

    Index.storage(index, storage)
  end

  @impl true
  def delete(index, ref) do
    storage =
      Enum.reduce(index.fields, index.storage, fn {k, _}, storage ->
        terms = Storage.fetch!(storage, Attr.Terms.key(ref: ref, field: k))

        Enum.reduce(terms, storage, fn term, storage ->
          k = key(field: k, term: term)
          total = Enum.count(Storage.fetch!(storage, Attr.Global.key())) - 1

          storage =
            Storage.update!(storage, k, fn {_, refs} ->
              idf(total, refs -- [ref])
            end)

          case Storage.fetch!(storage, k) do
            {0, []} -> Storage.delete(storage, k)
            _ -> storage
          end
        end)
      end)

    Index.storage(index, storage)
  end

  # Private

  defp idf(_total, []), do: {0, []}

  defp idf(total, refs) do
    {Float.round(:math.log10(total / Enum.count(refs))), refs}
  end
end
