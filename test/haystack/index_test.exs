defmodule Haystack.IndexTest do
  use ExUnit.Case, async: true

  alias Haystack.{Index, Storage}

  doctest Haystack.Index

  describe "new/2" do
    test "should create index" do
      index = Index.new(:animals)

      assert index.name == :animals
    end
  end

  describe "ref/2" do
    test "should add ref" do
      index = Index.new(:animals)
      index = Index.ref(index, Index.Field.new("id"))

      assert index.ref.k == "id"
    end
  end

  describe "field/2" do
    test "should add field" do
      index = Index.new(:animals)
      index = Index.field(index, Index.Field.new("name"))

      assert index.fields["name"].k == "name"
    end
  end
end
