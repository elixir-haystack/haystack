defmodule Haystack.StoreTest do
  use ExUnit.Case, async: true

  alias Haystack.{Index, Store}

  doctest Store

  setup do
    index =
      Index.new(:people)
      |> Index.ref(Index.Field.new("id"))
      |> Index.field(Index.Field.new("name"))

    {:ok, %{index: index}}
  end

  describe "insert/2" do
    test "should insert docs into store"
  end

  describe "update/2" do
    test "should update docs in the store"
  end

  describe "delete/2" do
    test "should delete docs from the store"
  end
end
