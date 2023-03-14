defmodule Haystack.Store do
  @moduledoc """
  A module for managing the data store.

  The store manages the interaction between applying the documents to the index.
  It does this by using the configured index :attrs and applying the correct
  action.
  """

  alias Haystack.{Index, Store}

  # Public

  @doc """
  Insert docs into the store.

    ## Examples

      iex> index = Index.new(:animals)
      iex> Store.insert(index, [])

  """
  @spec insert(Index.t(), list(Store.Document.t())) :: Index.t()
  def insert(index, docs) do
    Enum.reduce(docs, index, fn doc, index ->
      Enum.reduce(index.attrs.insert, index, fn module, index ->
        module.insert(index, doc)
      end)
    end)
  end

  @doc """
  Update docs in the store.

    ## Examples

      iex> index = Index.new(:animals)
      iex> Store.update(index, [])

  """
  @spec update(Index.t(), list(Store.Document.t())) :: Index.t()
  def update(index, docs) do
    index
    |> delete(Enum.map(docs, &Map.get(&1, :ref)))
    |> insert(docs)
  end

  @doc """
  Delete docs from the store.

    ## Examples

      iex> index = Index.new(:animals)
      iex> Store.delete(index, [])

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
