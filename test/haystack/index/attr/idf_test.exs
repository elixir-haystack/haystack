defmodule Haystack.Index.Attr.IDFTest do
  use ExUnit.Case, async: true

  import Haystack.Fixture

  alias Haystack.Storage
  alias Haystack.Index.Attr.{Docs, Global, IDF, Terms}

  setup do
    fixture(:animals)
  end

  describe "key/0" do
    test "should create key" do
      assert {:idf, "name", "red"} == IDF.key(field: "name", term: "red")
    end
  end

  describe "insert/2" do
    test "should insert", %{index: index, docs: docs} do
      index = Enum.reduce(docs, index, &Global.insert(&2, &1))
      index = Enum.reduce(docs, index, &Docs.insert(&2, &1))
      index = Enum.reduce(docs, index, &IDF.insert(&2, &1))

      key = IDF.key(field: "name", term: "red")

      assert 0.9030899869919435 == Storage.fetch!(index.storage, key)
    end
  end

  describe "delete/2" do
    test "should delete", %{index: index, docs: docs} do
      index = Enum.reduce(docs, index, &Global.insert(&2, &1))
      index = Enum.reduce(docs, index, &Docs.insert(&2, &1))
      index = Enum.reduce(docs, index, &Terms.insert(&2, &1))
      index = Enum.reduce(docs, index, &IDF.insert(&2, &1))
      index = Enum.reduce(docs, index, &IDF.delete(&2, &1.ref))

      key = IDF.key(field: "name", term: "red")

      assert {:error, _} = Storage.fetch(index.storage, key)
    end
  end
end
