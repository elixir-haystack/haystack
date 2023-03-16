defmodule Haystack.Index.Attr.GlobalTest do
  use ExUnit.Case, async: true

  import Haystack.Fixture

  alias Haystack.Index.Attr.Global
  alias Haystack.Storage

  setup do
    fixture(:animals)
  end

  describe "key/0" do
    test "should create key" do
      assert {:global} == Global.key()
    end
  end

  describe "insert/2" do
    test "should insert", %{index: index, docs: docs} do
      index = Enum.reduce(docs, index, &Global.insert(&2, &1))

      assert ~w{1 2 3 4 5 6 7 8} == Storage.fetch!(index.storage, Global.key())
    end
  end

  describe "delete/2" do
    test "should delete", %{index: index, docs: docs} do
      index = Enum.reduce(docs, index, &Global.insert(&2, &1))
      index = Global.delete(index, "1")

      assert ~w{2 3 4 5 6 7 8} == Storage.fetch!(index.storage, Global.key())
    end
  end
end
