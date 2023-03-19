defmodule Haystack.Query.IDF do
  @moduledoc """
  Calculate the IDF for the results.
  """

  alias Haystack.Index.Attr
  alias Haystack.Storage

  @doc """
  Calculate the IDF for each result.
  """
  @spec calculate(list(map), struct) :: list(map)
  def calculate(results, storage) do
    total = Enum.count(Storage.fetch!(storage, Attr.Global.key()))

    results
    |> Enum.group_by(& {&1.field, &1.term})
    |> Enum.flat_map(fn {{field, term}, results} ->
      count = Enum.count(Storage.fetch!(storage, Attr.Docs.key(field: field, term: term)))
      idf = :math.log10(total / count)

      Enum.map(results, &Map.put(&1, :idf, idf))
    end)
  end
end
