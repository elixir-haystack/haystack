defmodule Haystack.Store.Attr.GlobalTest do
  use ExUnit.Case, async: true

  import Haystack.Fixture

  alias Haystack.Storage
  alias Haystack.Store.Attr.Global

  setup do
    fixture(:animals) |> Map.put(:key, Global.key())
  end

  describe "key/0" do
    test "should create key", %{key: key} do
      assert {:global} == key
    end
  end

  describe "insert/2" do
    test "should insert", %{key: key, index: index, docs: docs} do
      index = Enum.reduce(docs, index, &Global.insert(&2, &1))

      assert ~w{1 2 3 4 5 6 7 8} == Storage.fetch!(index.storage, key)
    end
  end

  describe "delete/2" do
    test "should delete", %{key: key, index: index, docs: docs} do
      index = Enum.reduce(docs, index, &Global.insert(&2, &1))
      index = Global.delete(index, "1")

      assert ~w{2 3 4 5 6 7 8} == Storage.fetch!(index.storage, key)
    end
  end
end
