defmodule Haystack.Fixture do
  @moduledoc false

  alias Haystack.Fixture

  def data(:animals),
    do: Fixture.Animal.data()

  def fixture(:animals),
    do: Fixture.Animal.fixture()

  def index(:animals),
    do: Fixture.Animal.index()
end
