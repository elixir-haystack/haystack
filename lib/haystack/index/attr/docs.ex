defmodule Haystack.Index.Attr.Docs do
  @moduledoc """
  A module for returning a list of docs for a given field, term.
  """

  import Record

  alias Haystack.{Index, Storage}

  @behaviour Index.Attr

  defrecord :docs, field: nil, term: nil

  # Behaviour: Index.Attr

  @impl Index.Attr
  def key(field: field, term: term),
    do: docs(field: field, term: term)

  @impl Index.Attr
  def insert(index, %{ref: ref, fields: fields}, _opts \\ []) do
    storage =
      Enum.reduce(fields, index.storage, fn {field, terms}, storage ->
        Enum.reduce(terms, storage, fn term, storage ->
          k = key(field: field, term: term.v)
          Storage.upsert(storage, k, [ref], &[ref | &1])
        end)
      end)

    Index.storage(index, storage)
  end

  @impl Index.Attr
  def delete(index, %{ref: ref, fields: fields}, _opts \\ []) do
    storage =
      Enum.reduce(fields, index.storage, fn {field, terms}, storage ->
        Enum.reduce(terms, storage, fn term, storage ->
          k = key(field: field, term: term.v)

          case Storage.fetch!(storage, k) do
            [^ref] -> Storage.delete(storage, k)
            refs -> Storage.insert(storage, k, refs -- [ref])
          end
        end)
      end)

    Index.storage(index, storage)
  end
end
