defmodule Haystack.Query do
  @moduledoc """
  A module for building queries.
  """

  alias Haystack.{Index, Query}
  alias Haystack.Tokenizer.Token

  # Types

  @type statement :: (Query.t(), Index.t() -> list(map()))
  @type t :: %__MODULE__{
          clause: Query.Clause.t(),
          config: Keyword.t()
        }

  @enforce_keys ~w{index clause config}a

  defstruct @enforce_keys

  @config clause: Query.Clause.default(),
          expression: Query.Expression.default()

  # Public

  @doc """
  Create a new Query.
  """
  @spec new(Keyword.t()) :: t
  def new(opts \\ []),
    do: struct(__MODULE__, Keyword.put_new(opts, :config, @config))

  @doc """
  Add a clause to the query.
  """
  @spec clause(t, Query.Clause.t()) :: t
  def clause(query, clause),
    do: %{query | clause: clause}

  @doc """
  Evaluate a clause.
  """
  @spec evaluate(t(), Index.t(), Query.Clause.t(), list(statement)) :: list(map())
  def evaluate(query, index, clause, statements) do
    module = get_in(query.config, [:clause, clause.k])
    module.evaluate(query, index, statements)
  end

  @doc """
  Evaluate an expression.
  """
  @spec evaluate(t(), Index.t(), Query.Expression.t()) :: list(map())
  def evaluate(query, index, expression) do
    module = get_in(query.config, [:expression, expression.k])
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

      fields = Enum.group_by(fields, & &1.field)

      fields =
        Enum.map(fields, fn {k, list} ->
          {k, Enum.map(list, &Map.take(&1, [:positions, :term]))}
        end)

      %{ref: ref, score: score, fields: Map.new(fields)}
    end)
  end

  @doc """
  Build a clause for the given list of tokens.

  ## Examples

      iex> index = Index.new(:animals)
      iex> index = Index.field(index, Index.Field.new("name"))
      iex> tokens = Tokenizer.tokenize("Red Panda")
      iex> tokens = Transformer.pipeline(tokens, Transformer.default())
      iex> Query.build(:match_all, index, tokens)

  """
  @spec build(atom, Index.t(), list(Token.t())) :: Query.Clause.t()
  def build(:match_all, index, tokens) do
    Enum.reduce(tokens, Query.Clause.new(:all), fn token, clause ->
      Enum.reduce(Map.values(index.fields), clause, fn field, clause ->
        Query.Clause.expressions(clause, [
          Query.Expression.new(:match, field: field.k, term: token.v)
        ])
      end)
    end)
  end

  def build(:match_any, index, tokens) do
    Enum.reduce(tokens, Query.Clause.new(:any), fn token, clause ->
      Enum.reduce(Map.values(index.fields), clause, fn field, clause ->
        Query.Clause.expressions(clause, [
          Query.Expression.new(:match, field: field.k, term: token.v)
        ])
      end)
    end)
  end
end
