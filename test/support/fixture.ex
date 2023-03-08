defmodule Haystack.Fixture do
  @moduledoc """
  Fixture helpers for tests
  """

  alias __MODULE__
  alias Haystack.{Index, Store}

  @animals Fixture.Builder.build("/animals/*.json")

  @doc false
  def data(:animals), do: @animals

  @doc false
  def fixture(:animals) do
    data = data(:animals)
    index = index(:animals)
    docs = Enum.map(data, &Store.Document.new(index, &1))

    %{data: data, docs: docs, index: index}
  end

  @doc false
  def index(:animals) do
    Index.new(:animals)
    |> Index.ref(Index.Field.term("id"))
    |> Index.field(Index.Field.new("name"))
    |> Index.field(Index.Field.new("habitat"))
    |> Index.field(Index.Field.new("description"))
  end
end
