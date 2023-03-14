defmodule Haystack.Query.Expression do
  @moduledoc """
  A module for defining query expressions.
  """

  alias Haystack.{Index, Query}

  # Types

  @type k :: atom
  @type t :: %__MODULE__{
          k: k,
          field: String.t(),
          term: String.t()
        }

  @enforce_keys ~w{k field term}a

  defstruct @enforce_keys

  @expressions match: Query.Expression.Match

  # Behaviour

  @doc """
  Evaluate the given clause.
  """
  @callback evaluate(Index.t(), t) :: list(map())

  # Public

  @doc """
  Create a new expression.

  ## Examples

    iex> Query.Expression.new(:match, field: "name", term: "Haystack")

  """
  @spec new(k, Keyword.t()) :: t
  def new(k, opts),
    do: struct(__MODULE__, [k: k] ++ opts)

  @doc """
  Return the default expressions.

  ## Examples

    iex> Query.Expression.default()

  """
  @spec default :: [{atom, module}]
  def default, do: @expressions

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
end
