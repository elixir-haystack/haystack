defmodule Haystack.Query.Clause do
  @moduledoc """
  A module for defining query clauses.
  """

  alias Haystack.{Index, Query}
  alias Haystack.Query.Clause

  # Types

  @type k :: atom
  @type t :: %__MODULE__{
          k: k,
          clauses: list(t),
          expressions: list(Query.Expression.t())
        }

  @enforce_keys ~w{k clauses expressions}a

  defstruct @enforce_keys

  @clauses all: Clause.All,
           any: Clause.Any

  # Behaviour

  @doc """
  Evaluate the given clause.
  """
  @callback evaluate(Query.t(), Index.t(), list(Query.statement())) :: list(map())

  # Public

  @doc """
  Create a new clause.

  ## Examples

      iex> Query.Clause.new(:any)

  """
  @spec new(k) :: t
  def new(k),
    do: struct(__MODULE__, k: k, clauses: [], expressions: [])

  @doc """
  Return the default clauses.

  ## Examples

      iex> Query.Clause.default()

  """
  @spec default :: [{atom, module}]
  def default, do: @clauses

  @doc """
  Add a list of clauses.

  ## Examples

      iex> clause = Query.Clause.new(:any)
      iex> Query.Clause.clauses(clause, [Query.Clause.new(:any)])

  """
  def clauses(clause, clauses),
    do: %{clause | clauses: clause.clauses ++ clauses}

  @doc """
  Add a list of expressions.

  ## Examples

      iex> clause = Query.Clause.new(:any)
      iex> expression = Query.Expression.new(:match, field: "name", term: "Haystack")
      iex> Query.Clause.expressions(clause, [expression])

  """
  def expressions(clause, expressions),
    do: %{clause | expressions: clause.expressions ++ expressions}

  @doc """
  Build the clause into a statement.

  ## Examples

      iex> clause = Query.Clause.new(:any)
      iex> Query.Clause.build(clause)

  """
  @spec build(t) :: Query.statement()
  def build(clause) do
    fn query, index ->
      statements =
        clause.expressions
        |> Enum.map(&Query.Expression.build/1)
        |> Enum.concat(Enum.map(clause.clauses, &build/1))

      Query.evaluate(query, index, clause, statements)
    end
  end
end
