defmodule Haystack.Query.Clause do
  @moduledoc """
  A module for defining query clauses.
  """

  alias Haystack.{Index, Query}
  alias Haystack.Query.Clause

  @type key :: atom
  @type t :: %__MODULE__{
          key: key,
          clauses: list(t),
          expressions: list(Query.Expression.t())
        }

  defstruct ~w{key clauses expressions}a

  @clauses all: Clause.All

  @doc """
  Evaluate the given clause.
  """
  @callback evaluate(Query.t(), Index.t(), list(Query.statement())) :: list(map())

  @doc """
  Create a new clause.

  ## Examples

    iex> Query.Clause.new(:any)

  """
  @spec new(key) :: t
  def new(key) do
    struct(__MODULE__, key: key, clauses: [], expressions: [])
  end

  @doc """
  Add a list of clauses.

  ## Examples

    iex> clause = Query.Clause.new(:any)
    iex> Query.Clause.clauses(clause, [Query.Clause.new(:any)])

  """
  def clauses(clause, clauses) do
    %{clause | clauses: clause.clauses ++ clauses}
  end

  @doc """
  Add a list of expressions.

  ## Examples

    iex> clause = Query.Clause.new(:any)
    iex> expression = Query.Expression.new(:match, field: "name", term: "Haystack")
    iex> Query.Clause.expressions(clause, [expression])

  """
  def expressions(clause, expressions) do
    %{clause | expressions: clause.expressions ++ expressions}
  end

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

  @doc """
  Return the default clauses.

  ## Examples

    iex> Query.Clause.default()

  """
  def default, do: @clauses
end
