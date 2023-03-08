defmodule Haystack.Store.Attr.Terms do
  @moduledoc """
  A module for storing terms.
  """

  import Record

  alias Haystack.{Index, Storage, Store}

  @behaviour Store.Attr

  defrecord :terms, ref: nil, field: nil

  @impl true
  def key(opts) do
    terms(ref: Keyword.fetch!(opts, :ref), field: Keyword.fetch!(opts, :field))
  end

  @impl true
  def insert(index, %{ref: ref, fields: fields}) do
    storage =
      Enum.reduce(fields, index.storage, fn {k, terms}, storage ->
        k = key(ref: ref, field: k)
        v = Enum.map(terms, &Map.get(&1, :v))
        Storage.insert(storage, k, v)
      end)

    Index.storage(index, storage)
  end

  @impl true
  def delete(index, ref) do
    storage =
      Enum.reduce(index.fields, index.storage, fn {k, _}, storage ->
        Storage.delete(storage, key(ref: ref, field: k))
      end)

    Index.storage(index, storage)
  end
end
