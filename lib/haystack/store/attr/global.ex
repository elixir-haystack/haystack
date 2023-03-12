defmodule Haystack.Store.Attr.Global do
  @moduledoc """
  A module for storing the global list of refs.
  """

  import Record

  alias Haystack.{Index, Storage, Store}

  @behaviour Store.Attr

  defrecord :global, []

  @impl true
  def key(_opts \\ []), do: global()

  @impl true
  def insert(index, %{ref: ref}) do
    storage = Storage.upsert(index.storage, key(), [ref], &(&1 ++ [ref]))

    Index.storage(index, storage)
  end

  @impl true
  def delete(index, ref) do
    storage = Storage.upsert(index.storage, key(), ref, &(&1 -- [ref]))

    storage =
      case Storage.fetch!(storage, key()) do
        [] -> Storage.delete(storage, key())
        _ -> storage
      end

    Index.storage(index, storage)
  end
end
