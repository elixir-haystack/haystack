defmodule Haystack.Index.Attr.Terms do
  @moduledoc """
  A module for storing terms.
  """

  import Record

  alias Haystack.{Index, Storage}

  @behaviour Index.Attr

  defrecord :terms, ref: nil, field: nil

  # Behaviour: Index.Attr

  @impl Index.Attr
  def key(ref: ref, field: field),
    do: terms(ref: ref, field: field)

  @impl Index.Attr
  def insert(index, %{ref: ref, fields: fields}) do
    storage =
      Enum.reduce(fields, index.storage, fn {field, terms}, storage ->
        k = key(ref: ref, field: field)
        v = Enum.map(terms, &Map.get(&1, :v))
        Storage.insert(storage, k, v)
      end)

    Index.storage(index, storage)
  end

  @impl Index.Attr
  def delete(index, ref) do
    storage =
      Enum.reduce(index.fields, index.storage, fn {k, _}, storage ->
        Storage.delete(storage, key(ref: ref, field: k))
      end)

    Index.storage(index, storage)
  end
end
