defmodule Haystack.Store do
  @moduledoc """
  A module for managing the data store.
  """

  alias Haystack.Index

  @doc """
  Insert docs into the store.

  ## Examples

    iex> index = Index.new(:people)
    iex> Store.insert(index, [%{id: 1, name: "John Doe"}])

  """
  @spec insert(Index.t(), list(map)) :: Index.t()
  def insert(index, _docs) do
    index
  end

  @doc """
  Update docs in the store.

  ## Examples

    iex> index = Index.new(:people)
    iex> index = Store.insert(index, [%{id: 1, name: "John"}])
    iex> Store.update(index, [%{id: 1, name: "John Doe"}])

  """
  @spec update(Index.t(), list(map)) :: Index.t()
  def update(index, _docs) do
    index
  end

  @doc """
  Delete docs from the store.

  ## Examples

    iex> index = Index.new(:people)
    iex> index = Store.insert(index, [%{id: 1, name: "John"}])
    iex> Store.delete(index, [1])

  """
  @spec delete(Index.t(), list(term)) :: Index.t()
  def delete(index, _refs) do
    index
  end
end
