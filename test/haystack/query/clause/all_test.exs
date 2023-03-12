defmodule Haystack.Query.Clause.AllTest do
  use ExUnit.Case, async: true

  import Haystack.Fixture

  alias Haystack.{Index, Query}
  alias Haystack.Query.{Clause, Expression}

  setup do
    fixture(:animals)
  end

  describe "evaluate/2" do
    test "should not match", %{index: index, data: data} do
      query = Query.new(Index.add(index, data))

      clause =
        Clause.expressions(Clause.new(:all), [
          Expression.new(:match, field: "name", term: "invalid")
        ])

      statements = [Clause.build(clause)]

      assert Enum.empty?(Clause.All.evaluate(query, statements))
    end

    test "should match", %{index: index, data: data} do
      query = Query.new(Index.add(index, data))

      clause =
        Clause.expressions(Clause.new(:all), [
          Expression.new(:match, field: "name", term: "panda")
        ])

      statements = [Clause.build(clause)]

      assert Enum.count(Clause.All.evaluate(query, statements)) == 2
    end
  end
end
