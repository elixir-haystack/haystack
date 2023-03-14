defmodule Haystack.Store.Attr do
  @moduledoc """
  A behaviour for defining a store attr.
  """

  alias Haystack.{Index, Store}

  @attrs [
    Store.Attr.Global,
    Store.Attr.Terms,
    Store.Attr.Docs,
    Store.Attr.Meta
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
  @callback insert(Index.t(), Store.Document.t()) :: Index.t()

  @doc """
  Delete an attr.
  """
  @callback delete(Index.t(), Store.Document.t()) :: Index.t()

  # Public

  @doc """
  Return the default attrs.
  """
  @spec default :: %{insert: list(module), delete: list(module)}
  def default, do: %{insert: attrs(), delete: Enum.reverse(attrs())}

  # Private

  defp attrs, do: @attrs
end
