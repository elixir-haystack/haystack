defmodule Haystack.Query do
  @moduledoc """
  A module for defining queries.
  """

  alias Haystack.{Index, Query}

  @type statement :: (Query.t(), Index.t() -> list(map()))
  @type t :: %__MODULE__{
          clause: Query.Clause.t(),
          config: Keyword.t()
        }

  defstruct ~w{index clause config}a

  @doc """
  Create a new Query.
  """
  @spec new(Keyword.t()) :: t
  def new(opts \\ []) do
    opts = Keyword.put_new(opts, :config, default())

    struct(__MODULE__, opts)
  end

  @doc """
  Add a clause to the query.
  """
  @spec clause(t, Query.Clause.t()) :: t
  def clause(query, clause) do
    %{query | clause: clause}
  end

  @doc """
  Evaluate a clause.
  """
  @spec evaluate(t(), Index.t(), Query.Clause.t(), list(statement)) :: list(map())
  def evaluate(query, index, clause, statements) do
    module = get_in(query.config, [:clauses, clause.key])
    module.evaluate(query, index, statements)
  end

  @doc """
  Evaluate an expression.
  """
  @spec evaluate(t(), Index.t(), Query.Expression.t()) :: list(map())
  def evaluate(query, index, expression) do
    module = get_in(query.config, [:expressions, expression.key])
    module.evaluate(index, expression)
  end

  @doc """
  Run the given query.
  """
  @spec run(t, Index.t()) :: list(map)
  def run(query, index) do
    statement = Query.Clause.build(query.clause)
    responses = statement.(query, index)

    responses
    |> Enum.group_by(& &1.ref)
    |> Enum.map(fn {ref, fields} ->
      score = Enum.reduce(fields, 0, &(&1.score + &2))

      fields =
        Enum.map(fields, fn %{field: field, positions: positions} ->
          %{k: field, positions: positions}
        end)

      %{ref: ref, score: score, fields: fields}
    end)
  end

  # Private

  defp default do
    [clauses: Query.Clause.default(), expressions: Query.Expression.default()]
  end
end
