defmodule HaystackTest do
  use ExUnit.Case, async: true

  import Haystack.Fixture

  alias Haystack.Index

  doctest Haystack

  describe "new/1" do
    test "should create haystack" do
      assert %Haystack{} = Haystack.new()
    end
  end

  describe "index/3" do
    setup do
      fixture(:animals)
    end

    test "should use index", %{data: data} do
      results =
        Haystack.index(Haystack.new(), :animals, fn index ->
          index
          |> Index.ref(Index.Field.term("id"))
          |> Index.field(Index.Field.new("name"))
          |> Index.field(Index.Field.new("description"))
          |> Index.add(data)
          |> Index.search("panda")
        end)

      assert Enum.count(results) == 2
    end
  end
end
