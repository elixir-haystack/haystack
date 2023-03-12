defmodule Haystack.Store do
  @moduledoc """
  A module for managing the data store.
  """

  alias Haystack.Index
  alias Haystack.Store.Document

  @doc """
  Insert docs into the store.
  """
  @spec insert(Index.t(), list(Document.t())) :: Index.t()
  def insert(index, docs) do
    Enum.reduce(docs, index, fn doc, index ->
      Enum.reduce(index.attrs.insert, index, fn module, index ->
        module.insert(index, doc)
      end)
    end)
  end

  @doc """
  Update docs in the store.
  """
  @spec update(Index.t(), list(Document.t())) :: Index.t()
  def update(index, docs) do
    index = delete(index, Enum.map(docs, &Map.get(&1, :ref)))

    insert(index, docs)
  end

  @doc """
  Delete docs from the store.
  """
  @spec delete(Index.t(), list(term)) :: Index.t()
  def delete(index, refs) do
    Enum.reduce(refs, index, fn ref, index ->
      Enum.reduce(index.attrs.delete, index, fn module, index ->
        module.delete(index, ref)
      end)
    end)
  end
end
