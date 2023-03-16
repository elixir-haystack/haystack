defmodule Haystack.Index.Attr do
  @moduledoc """
  A behaviour for defining a store attr.
  """

  alias Haystack.Index

  @attrs [
    Index.Attr.Global,
    Index.Attr.Terms,
    Index.Attr.Docs,
    Index.Attr.IDF,
    Index.Attr.Meta
  ]

  # Types

  @type opts :: Keyword.t()

  # Behaviour

  @doc """
  The attr key.
  """
  @callback key(opts) :: tuple

  @doc """
  Insert an attr.
  """
  @callback insert(Index.t(), Index.Document.t()) :: Index.t()

  @doc """
  Delete an attr.
  """
  @callback delete(Index.t(), Index.Document.t()) :: Index.t()

  # Public

  @doc """
  Return the default attrs.
  """
  @spec default :: %{insert: list(module), delete: list(module)}
  def default, do: %{insert: @attrs, delete: Enum.reverse(@attrs)}
end
