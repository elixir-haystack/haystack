defmodule Haystack.Fixture.Builder do
  @moduledoc """
  A helper module to build fixture data from json files
  """

  @dir Application.app_dir(:haystack, "/priv/haystack/fixtures")

  @doc false
  def build(path) do
    Enum.map(Path.wildcard(Path.join(@dir, path)), fn path ->
      path
      |> File.read!()
      |> Jason.decode!(keys: :atoms)
      |> Map.put(:id, Path.basename(path, ".json"))
    end)
  end
end
