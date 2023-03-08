defmodule Haystack.Fixture do
  @moduledoc """
  Fixture helpers for tests
  """

  alias __MODULE__
  alias Haystack.Index

  @animals Fixture.Builder.build("/animals/*.json")

  @doc false
  def data(:animals), do: @animals

  @doc false
  def fixture(:animals),
    do: %{index: index(:animals), data: data(:animals)}

  @doc false
  def index(:animals) do
    Index.new(:animals)
    |> Index.ref(Index.Field.term("id"))
    |> Index.field(Index.Field.new("name"))
    |> Index.field(Index.Field.new("habitat"))
    |> Index.field(Index.Field.new("description"))
  end
end
