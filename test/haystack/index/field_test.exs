defmodule Haystack.Index.FieldTest do
  use ExUnit.Case, async: true

  alias Haystack.{Index, Tokenizer}

  doctest Index.Field

  describe "new/1" do
    test "should create field" do
      field = Index.Field.new("title")

      assert field.k == "title"
      assert field.path == ["title"]
    end

    test "should created nested field" do
      field = Index.Field.new("address.town")

      assert field.k == "address.town"
      assert field.path == ["address", "town"]
    end
  end

  describe "term/1" do
    test "should create term field" do
      field = Index.Field.term("id")

      assert field.k == "id"
      assert field.path == ["id"]
      assert field.transformers == []
      assert field.separator == Tokenizer.separator(:full)
    end
  end
end
