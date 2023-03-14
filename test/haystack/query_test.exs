defmodule Haystack.QueryTest do
  use ExUnit.Case, async: true

  import Haystack.Fixture

  alias Haystack.{Index, Query, Tokenizer, Transformer}

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

  describe "build/3" do
    test "should build match all", %{index: index, data: data} do
      index = Index.add(index, data)
      tokens = Tokenizer.tokenize("red panda")
      tokens = Transformer.pipeline(tokens, Transformer.default())

      query = Query.clause(Query.new(), Query.build(:match_all, index, tokens))

      assert Enum.count(Query.run(query, index)) == 1
    end
  end
end
