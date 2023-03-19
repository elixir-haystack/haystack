defmodule Haystack.IndexTest do
  use ExUnit.Case, async: true

  import Haystack.Fixture

  alias Haystack.{Index, Storage}

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

      assert index.ref.k == "id"
    end
  end

  describe "field/2" do
    test "should add field" do
      index = Index.new(:animals)
      index = Index.field(index, Index.Field.new("name"))

      assert index.fields["name"].k == "name"
    end
  end

  describe "add/2" do
    test "should add", %{index: index, data: data} do
      index = Index.add(index, data)

      assert Storage.count(index.storage) > 0
    end
  end

  describe "delete/2" do
    test "should delete", %{index: index, data: data} do
      index = Index.add(index, data)
      index = Index.delete(index, Enum.map(data, & &1))

      assert Storage.count(index.storage) == 0
    end
  end

  describe "search/2" do
    test "should search", %{index: index, data: data} do
      index = Index.add(index, data)

      assert Enum.empty?(Index.search(index, "dog"))
      assert Enum.count(Index.search(index, "panda")) == 2
    end
  end
end
