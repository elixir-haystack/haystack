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
      index = Index.add(index, data)
      query = Query.new()

      clause =
        Query.Clause.expressions(Query.Clause.new(:all), [
          Query.Expression.new(:match, field: "name", term: "panda"),
          Query.Expression.new(:match, field: "description", term: "panda")
        ])

      query = Query.clause(query, clause)

      assert Enum.count(Query.run(query, index)) == 2
    end
  end
end
