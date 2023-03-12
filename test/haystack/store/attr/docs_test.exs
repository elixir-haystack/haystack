defmodule Haystack.Store.Attr.DocsTest do
  use ExUnit.Case, async: true

  import Haystack.Fixture

  alias Haystack.Storage
  alias Haystack.Store.Attr.{Docs, Global, Terms}

  setup do
    fixture(:animals) |> Map.put(:key, Docs.key(field: "name", term: "red"))
  end

  describe "key/0" do
    test "should create key", %{key: key} do
      assert {:docs, "name", "red"} == key
    end
  end

  describe "insert/2" do
    test "should insert", %{key: key, index: index, docs: docs} do
      index = Enum.reduce(docs, index, &Global.insert(&2, &1))
      index = Enum.reduce(docs, index, &Docs.insert(&2, &1))

      assert {1.0, ["1"]} = Storage.fetch!(index.storage, key)
    end
  end

  describe "delete/2" do
    test "should delete", %{key: key, index: index, docs: docs} do
      index = Enum.reduce(docs, index, &Global.insert(&2, &1))
      index = Enum.reduce(docs, index, &Terms.insert(&2, &1))
      index = Enum.reduce(docs, index, &Docs.insert(&2, &1))
      index = Enum.reduce(docs, index, &Docs.delete(&2, &1.ref))

      assert {:error, _} = Storage.fetch(index.storage, key)
    end
  end
end
