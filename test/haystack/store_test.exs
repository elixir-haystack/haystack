defmodule Haystack.StoreTest do
  use ExUnit.Case, async: true

  import Haystack.Fixture

  alias Haystack.{Index, Storage, Store}
  alias Haystack.Store.Attr.Terms
  alias Haystack.Store.Document

  doctest Store

  setup do
    fixture(:animals)
  end

  describe "insert/2" do
    test "should insert", %{index: index, docs: docs} do
      key = Terms.key(ref: "1", field: "name")

      index = Store.insert(index, docs)

      assert ~w{panda red} = Storage.fetch!(index.storage, key) |> Enum.sort()
    end
  end

  describe "update/2" do
    test "should update", %{index: index, data: data, docs: docs} do
      key = Terms.key(ref: "1", field: "name")
      index = Store.insert(index, docs)

      doc =
        data
        |> List.first()
        |> Map.put(:name, "Blue Panda")
        |> then(&Document.new(index, &1))

      index = Store.update(index, [doc])

      assert ~w{blue panda} = Storage.fetch!(index.storage, key) |> Enum.sort()
    end
  end

  describe "delete/2" do
    test "should delete", %{index: index, docs: docs} do
      key = Terms.key(ref: "1", field: "name")
      index = Store.insert(index, docs)
      index = Store.delete(index, Enum.map(docs, &Map.get(&1, :ref)))

      assert {:error, _} = Storage.fetch(index.storage, key)
    end
  end
end
