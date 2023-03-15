defmodule Haystack.Query.Clause.Any do
  @moduledoc """
  A module to define "any" clauses.
  """

  alias Haystack.Query

  @behaviour Query.Clause

  # Query.Clause

  @impl Query.Clause
  def evaluate(query, index, statements) do
    responses = Enum.map(statements, & &1.(query, index))

    [result | results] =
      Enum.map(responses, fn results ->
        results
        |> Enum.map(&Map.get(&1, :ref))
        |> MapSet.new()
      end)

    refs = Enum.reduce(results, result, &MapSet.union(&2, &1))

    responses
    |> List.flatten()
    |> Enum.filter(&Enum.member?(refs, &1.ref))
  end
end
