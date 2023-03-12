defmodule Haystack.Fixture.Animal do
  @moduledoc false

  use Haystack.Fixture.Builder,
    key: :animals,
    from: Application.app_dir(:haystack, "/priv/haystack/fixtures/animals/*.json")

  alias Haystack.{Index, Store}

  def data,
    do: @animals

  def fixture do
    data = data()
    index = index()
    docs = Enum.map(data, &Store.Document.new(index, &1))

    %{data: data, docs: docs, index: index}
  end

  def index do
    Index.new(:animals)
    |> Index.ref(Index.Field.term("id"))
    |> Index.field(Index.Field.new("name"))
    |> Index.field(Index.Field.new("habitat"))
    |> Index.field(Index.Field.new("description"))
  end
end
