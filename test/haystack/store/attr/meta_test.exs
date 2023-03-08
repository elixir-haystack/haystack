defmodule Haystack.Store.Attr.MetaTest do
  use ExUnit.Case, async: true

  import Haystack.Fixture

  alias Haystack.Storage
  alias Haystack.Store.Attr.{Meta, Terms}

  setup do
    key = Meta.key(ref: "1", field: "name", term: "red")

    fixture(:animals) |> Map.put(:key, key)
  end

  describe "key/0" do
    test "should create key", %{key: key} do
      assert {:meta, "1", "name", "red"} == key
    end
  end

  describe "insert/2" do
    test "should insert", %{key: key, index: index, docs: docs} do
      %{storage: storage} = Enum.reduce(docs, index, &Meta.insert(&2, &1))

      assert %{positions: [{0, 3}]} == Storage.fetch!(storage, key)
    end
  end

  describe "delete/2" do
    test "should delete", %{key: key, index: index, docs: docs} do
      index = Enum.reduce(docs, index, &Terms.insert(&2, &1))
      index = Enum.reduce(docs, index, &Meta.insert(&2, &1))
      index = Enum.reduce(docs, index, &Meta.delete(&2, &1.ref))

      assert {:error, _} = Storage.fetch(index.storage, key)
    end
  end
end
