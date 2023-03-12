defmodule Haystack.QueryTest do
  use ExUnit.Case, async: true

  import Haystack.Fixture

  alias Haystack.{Index, Query}

  doctest Haystack.Query

  setup do
    fixture(:animals)
  end

  describe "run/2" do
    test "should run query", %{index: index, data: data} do
      query = Query.new(Index.add(index, data))

      clause =
        Query.Clause.expressions(Query.Clause.new(:all), [
          Query.Expression.new(:match, field: "name", term: "panda"),
          Query.Expression.new(:match, field: "description", term: "panda")
        ])

      query = Query.clause(query, clause)

      assert Enum.count(Query.run(query)) == 2
    end
  end
end
