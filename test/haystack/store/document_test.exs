defmodule Haystack.Store.DocumentTest do
  use ExUnit.Case, async: true

  import Haystack.Fixture

  alias Haystack.Store

  doctest Store.Document

  setup do
    fixture(:animals)
  end

  describe "new/2" do
    test "should create document", %{index: index, data: data} do
      assert %Store.Document{} = Store.Document.new(index, hd(data))
    end

    test "should extract refs", %{index: index, data: data} do
      docs = Enum.map(data, &Store.Document.new(index, &1))

      assert ~w{1 2 3 4 5 6 7 8} = Enum.map(docs, &Map.get(&1, :ref))
    end

    test "should extract fields", %{index: index, data: data} do
      docs = Enum.map(data, &Store.Document.new(index, &1))

      for %{fields: fields} <- docs do
        assert Map.has_key?(fields, "name")
        assert Map.has_key?(fields, "description")
      end
    end

    test "should tokenize and transform fields", %{index: index, data: data} do
      %{fields: %{"name" => tokens}} = Store.Document.new(index, hd(data))
      tokens = Enum.sort_by(tokens, & &1.v)

      assert ~w{panda red} == Enum.map(tokens, & &1.v)
      assert [0.5, 0.5] == Enum.map(tokens, & &1.tf)
      assert [[{4, 5}], [{0, 3}]] == Enum.map(tokens, & &1.positions)
    end
  end
end
