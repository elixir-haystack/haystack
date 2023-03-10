defmodule Haystack.Query.Expression.MatchTest do
  use ExUnit.Case, async: true

  import Haystack.Fixture

  alias Haystack.{Index, Query}
  alias Haystack.Query.Expression.Match

  setup do
    fixture(:animals)
  end

  describe "evaluate/2" do
    test "should not match", %{index: index, data: data} do
      index = Index.add(index, data)
      expression = Query.Expression.new(:match, field: "name", term: "invalid")

      assert Enum.empty?(Match.evaluate(index, expression))
    end

    test "should match", %{index: index, data: data} do
      index = Index.add(index, data)
      expression = Query.Expression.new(:match, field: "name", term: "panda")

      assert Enum.count(Match.evaluate(index, expression)) == 2
    end
  end
end
