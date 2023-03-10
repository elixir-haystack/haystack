defmodule Haystack.IndexTest do
  use ExUnit.Case, async: true

  import Haystack.Fixture

  alias Haystack.{Index, Query, Storage}

  doctest Haystack.Index

  setup do
    fixture(:animals)
  end

  describe "new/2" do
    test "should create index" do
      index = Index.new(:animals)

      assert index.name == :animals
    end
  end

  describe "ref/2" do
    test "should add ref" do
      index = Index.new(:animals)
      index = Index.ref(index, Index.Field.new("id"))

      assert index.ref.key == "id"
    end
  end

  describe "field/2" do
    test "should add field" do
      index = Index.new(:animals)
      index = Index.field(index, Index.Field.new("name"))

      assert index.fields["name"].key == "name"
    end
  end

  describe "add/2" do
    test "should add", %{index: index, data: data} do
      index = Index.add(index, data)

      assert Storage.count(index.storage) > 0
    end
  end

  describe "update/2" do
    test "should update", %{index: index, data: [data | rest]} do
      clause =
        Query.Clause.expressions(Query.Clause.new(:all), [
          Query.Expression.new(:match, field: "name", term: "otter")
        ])

      query = Query.clause(Query.new(), clause)

      index = Index.add(index, [data | rest])

      assert Enum.empty?(Index.search(index, query))

      data = Map.put(data, :name, "Otter")

      index = Index.update(index, [data])

      assert Enum.count(Index.search(index, query)) == 1
    end
  end

  describe "delete/2" do
    test "should delete", %{index: index, data: data} do
      index = Index.add(index, data)
      index = Index.delete(index, Enum.map(data, & &1.id))

      assert Storage.count(index.storage) == 0
    end
  end

  describe "search/2" do
    test "should search", %{index: index, data: data} do
      index = Index.add(index, data)

      clause =
        Query.Clause.expressions(Query.Clause.new(:all), [
          Query.Expression.new(:match, field: "name", term: "dog")
        ])

      query = Query.clause(Query.new(), clause)

      assert Enum.empty?(Index.search(index, query))

      clause =
        Query.Clause.expressions(Query.Clause.new(:all), [
          Query.Expression.new(:match, field: "name", term: "panda")
        ])

      query = Query.clause(Query.new(), clause)

      assert Enum.count(Index.search(index, query)) == 2
    end
  end
end
