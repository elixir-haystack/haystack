defmodule Haystack.Store.Attr.TermsTest do
  use ExUnit.Case, async: true

  import Haystack.Fixture

  alias Haystack.Storage
  alias Haystack.Store.Attr.Terms

  setup do
    fixture(:animals)
  end

  describe "key/0" do
    test "should create key" do
      assert {:terms, "1", "name"} == Terms.key(ref: "1", field: "name")
    end
  end

  describe "insert/2" do
    test "should insert", %{index: index, docs: docs} do
      index = Enum.reduce(docs, index, &Terms.insert(&2, &1))

      key = Terms.key(ref: "1", field: "name")

      assert ~w{panda red} = Storage.fetch!(index.storage, key) |> Enum.sort()
    end
  end

  describe "delete/2" do
    test "should delete", %{index: index, docs: docs} do
      index = Enum.reduce(docs, index, &Terms.insert(&2, &1))
      index = Enum.reduce(docs, index, &Terms.delete(&2, &1.ref))

      key = Terms.key(ref: "1", field: "name")

      assert {:error, _} = Storage.fetch(index.storage, key)
    end
  end
end
