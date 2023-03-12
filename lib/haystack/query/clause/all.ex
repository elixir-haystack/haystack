defmodule Haystack.Query.Clause.All do
  @moduledoc """
  A module to define "all" clauses.
  """

  alias Haystack.Query

  @behaviour Query.Clause

  @impl true
  def evaluate(query, statements) do
    responses = Enum.map(statements, & &1.(query))

    [result | results] =
      Enum.map(responses, fn results ->
        results
        |> Enum.map(&Map.get(&1, :ref))
        |> MapSet.new()
      end)

    refs = Enum.reduce(results, result, &MapSet.intersection(&2, &1))

    responses
    |> List.flatten()
    |> Enum.filter(&Enum.member?(refs, &1.ref))
  end
end
