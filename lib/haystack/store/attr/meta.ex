defmodule Haystack.Store.Attr.Meta do
  @moduledoc """
  A module for storing the meta for a field, term.
  """

  import Record

  alias Haystack.{Index, Storage, Store}
  alias Haystack.Store.Attr

  @behaviour Store.Attr

  defrecord :meta, ref: nil, field: nil, term: nil

  # Behaviour: Store.Attr

  @impl Store.Attr
  def key(ref: ref, field: field, term: term),
    do: meta(ref: ref, field: field, term: term)

  @impl Store.Attr
  def insert(index, %{ref: ref, fields: fields}) do
    storage =
      Enum.reduce(fields, index.storage, fn {field, terms}, storage ->
        Enum.reduce(terms, storage, fn term, storage ->
          k = key(ref: ref, field: field, term: term.v)
          Storage.insert(storage, k, Map.take(term, [:positions, :tf]))
        end)
      end)

    Index.storage(index, storage)
  end

  @impl Store.Attr
  def delete(index, ref) do
    storage =
      Enum.reduce(index.fields, index.storage, fn {k, _}, storage ->
        terms = Storage.fetch!(storage, Attr.Terms.key(ref: ref, field: k))

        Enum.reduce(terms, storage, fn term, storage ->
          Storage.delete(storage, key(ref: ref, field: k, term: term))
        end)
      end)

    Index.storage(index, storage)
  end
end
