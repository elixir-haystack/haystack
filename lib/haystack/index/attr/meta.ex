defmodule Haystack.Index.Attr.Meta do
  @moduledoc """
  A module for storing the meta for a field, term.
  """

  import Record

  alias Haystack.{Index, Storage}

  @behaviour Index.Attr

  defrecord :meta, ref: nil, field: nil, term: nil

  # Behaviour: Index.Attr

  @impl Index.Attr
  def key(ref: ref, field: field, term: term),
    do: meta(ref: ref, field: field, term: term)

  @impl Index.Attr
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

  @impl Index.Attr
  def delete(index, %{ref: ref, fields: fields}) do
    storage =
      Enum.reduce(fields, index.storage, fn {field, terms}, storage ->
        Enum.reduce(terms, storage, fn term, storage ->
          k = key(ref: ref, field: field, term: term.v)
          Storage.delete(storage, k)
        end)
      end)

    Index.storage(index, storage)
  end
end
