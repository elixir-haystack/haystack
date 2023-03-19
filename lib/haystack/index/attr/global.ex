defmodule Haystack.Index.Attr.Global do
  @moduledoc """
  A module for storing the global list of refs.
  """

  import Record

  alias Haystack.{Index, Storage}

  @behaviour Index.Attr

  defrecord :global, []

  # Behaviour: Index.Attr

  @impl Index.Attr
  def key(_opts \\ []), do: global()

  @impl Index.Attr
  def insert(index, %{ref: ref}) do
    storage = Storage.upsert(index.storage, key(), [ref], &(&1 ++ [ref]))

    Index.storage(index, storage)
  end

  @impl Index.Attr
  def delete(index, %{ref: ref}) do
    storage = Storage.upsert(index.storage, key(), ref, &(&1 -- [ref]))

    storage =
      case Storage.fetch!(storage, key()) do
        [] -> Storage.delete(storage, key())
        _ -> storage
      end

    Index.storage(index, storage)
  end
end
