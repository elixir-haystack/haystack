defmodule Haystack.Index.Attr.MetaTest do
  use ExUnit.Case, async: true

  import Haystack.Fixture

  alias Haystack.Index.Attr.Meta
  alias Haystack.Storage

  setup do
    fixture(:animals)
  end

  describe "key/0" do
    test "should create key" do
      key = Meta.key(ref: "1", field: "name", term: "red")

      assert {:meta, "1", "name", "red"} == key
    end
  end

  describe "insert/2" do
    test "should insert", %{index: index, docs: docs} do
      %{storage: storage} = Enum.reduce(docs, index, &Meta.insert(&2, &1))

      key = Meta.key(ref: "1", field: "name", term: "red")

      assert %{positions: [{0, 3}], tf: 0.5} == Storage.fetch!(storage, key)
    end
  end

  describe "delete/2" do
    test "should delete", %{index: index, docs: docs} do
      index = Enum.reduce(docs, index, &Meta.insert(&2, &1))
      index = Enum.reduce(docs, index, &Meta.delete(&2, &1))

      key = Meta.key(ref: "1", field: "name", term: "red")

      assert {:error, _} = Storage.fetch(index.storage, key)
    end
  end
end
