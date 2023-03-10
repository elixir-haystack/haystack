defmodule Haystack.Query.Expression do
  @moduledoc """
  A module for defining query expressions.
  """

  alias Haystack.{Index, Query}

  @type key :: atom
  @type t :: %__MODULE__{
          key: key,
          field: String.t(),
          term: String.t()
        }

  defstruct ~w{key field term}a

  @expressions match: Query.Expression.Match

  @doc """
  Evaluate the given clause.
  """
  @callback evaluate(Index.t(), t) :: list(map())

  @doc """
  Create a new expression.

  ## Examples

    iex> Query.Expression.new(:match, field: "name", term: "Haystack")

  """
  @spec new(key, Keyword.t()) :: t
  def new(key, opts) do
    struct(__MODULE__, [key: key] ++ opts)
  end

  @doc """
  Build the expression into a statement.

  ## Examples

    iex> expression = Query.Expression.new(:match, field: "name", term: "Haystack")
    iex> Query.Expression.build(expression)

  """
  @spec build(t) :: Query.statement()
  def build(expression) do
    fn query, index ->
      Query.evaluate(query, index, expression)
    end
  end

  def default, do: @expressions
end
