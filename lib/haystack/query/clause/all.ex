defmodule Haystack.Query.Clause.All do
  @moduledoc """
  A module to define "all" clauses.
  """

  alias Haystack.Query

  @behaviour Query.Clause

  # Behaviour: Query.Clause

  @impl Query.Clause
  def evaluate(query, index, statements) do
    responses = Enum.map(statements, & &1.(query, index))

    results =
      Enum.map(responses, fn results ->
        results
        |> Enum.map(&Map.get(&1, :ref))
        |> MapSet.new()
      end)

    {acc, results} = List.pop_at(results, 0, MapSet.new())

    refs = Enum.reduce(results, acc, &MapSet.intersection(&2, &1))

    responses
    |> List.flatten()
    |> Enum.filter(&Enum.member?(refs, &1.ref))
  end
end
