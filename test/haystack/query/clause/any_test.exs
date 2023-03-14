defmodule Haystack.Query.Clause.AnyTest do
  use ExUnit.Case, async: true

  import Haystack.Fixture

  alias Haystack.{Index, Query}
  alias Haystack.Query.{Clause, Expression}

  setup do
    fixture(:animals)
  end

  describe "evaluate/2" do
    test "should not match", %{index: index, data: data} do
      query = Query.new()
      index = Index.add(index, data)

      clause =
        Clause.expressions(Clause.new(:any), [
          Expression.new(:match, field: "name", term: "invalid"),
          Expression.new(:match, field: "name", term: "whatsup")
        ])

      statements = [Clause.build(clause)]

      assert Enum.empty?(Clause.Any.evaluate(query, index, statements))
    end

    test "should match", %{index: index, data: data} do
      query = Query.new()
      index = Index.add(index, data)

      clause =
        Clause.expressions(Clause.new(:any), [
          Expression.new(:match, field: "name", term: "panda"),
          Expression.new(:match, field: "name", term: "invalid")
        ])

      statements = [Clause.build(clause)]

      assert Enum.count(Clause.Any.evaluate(query, index, statements)) == 2
    end
  end
end
