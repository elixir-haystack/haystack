defmodule HaystackTest do
  use ExUnit.Case
  doctest Haystack

  test "greets the world" do
    assert Haystack.hello() == :world
  end
end
