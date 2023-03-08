defmodule Haystack.Index.FieldTest do
  use ExUnit.Case, async: true

  alias Haystack.Index

  doctest Index.Field

  describe "new/1" do
    test "should create field" do
      field = Index.Field.new("title")

      assert field.k == "title"
      assert field.path == ["title"]

      field = Index.Field.new("address.town")

      assert field.k == "address.town"
      assert field.path == ["address", "town"]
    end
  end

  describe "term/1" do
    test "should create new term field" do
      field = Index.Field.term("id")

      assert field.k == "id"
      assert field.path == ["id"]
      assert field.transformers == []
    end
  end
end
