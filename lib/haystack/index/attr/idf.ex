defmodule Haystack.Index.Attr.IDF do
  @moduledoc """
  A module for calculating Inverse Document Frequency.
  """

  import Record

  alias Haystack.{Index, Storage}
  alias Haystack.Index.Attr

  @behaviour Index.Attr

  defrecord :idf, field: nil, term: nil

  # Behaviour: Index.Attr

  @impl Index.Attr
  def key(field: field, term: term),
    do: idf(field: field, term: term)

  @impl Index.Attr
  def insert(index, %{fields: fields}) do
    storage =
      Enum.reduce(fields, index.storage, fn {field, terms}, storage ->
        Enum.reduce(terms, storage, fn %{v: v}, storage ->
          k = key(field: field, term: v)
          total = Enum.count(Storage.fetch!(storage, Attr.Global.key()))
          count = Enum.count(Storage.fetch!(storage, Attr.Docs.key(field: field, term: v)))

          Storage.insert(storage, k, :math.log10(total / count))
        end)
      end)

    Index.storage(index, storage)
  end

  @impl Index.Attr
  def delete(index, %{fields: fields}) do
    storage =
      Enum.reduce(fields, index.storage, fn {field, terms}, storage ->
        Enum.reduce(terms, storage, fn %{v: v}, storage ->
          k = key(field: field, term: v)
          total = Enum.count(Storage.fetch!(storage, Attr.Global.key())) - 1
          count = Enum.count(Storage.fetch!(storage, Attr.Docs.key(field: field, term: v))) - 1

          if count == 0 do
            Storage.delete(storage, k)
          else
            Storage.insert(storage, k, :math.log10(total / count))
          end
        end)
      end)

    Index.storage(index, storage)
  end
end
