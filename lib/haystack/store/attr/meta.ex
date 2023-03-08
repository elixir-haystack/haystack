defmodule Haystack.Store.Attr.Meta do
  @moduledoc """
  A module for storing the meta for a field, term.
  """

  import Record

  alias Haystack.{Index, Storage, Store}
  alias Haystack.Store.Attr

  @behaviour Store.Attr

  defrecord :meta, ref: nil, field: nil, term: nil

  @impl true
  def key(opts) do
    ref = Keyword.fetch!(opts, :ref)
    field = Keyword.fetch!(opts, :field)
    term = Keyword.fetch!(opts, :term)

    meta(ref: ref, field: field, term: term)
  end

  @impl true
  def insert(index, %{ref: ref, fields: fields}) do
    storage =
      Enum.reduce(fields, index.storage, fn {field, terms}, storage ->
        Enum.reduce(terms, storage, fn term, storage ->
          k = key(ref: ref, field: field, term: term.v)
          Storage.insert(storage, k, %{positions: term.positions})
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
          Storage.delete(storage, key(ref: ref, field: k, term: term))
        end)
      end)

    Index.storage(index, storage)
  end
end
