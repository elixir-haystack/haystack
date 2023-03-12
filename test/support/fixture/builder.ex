defmodule Haystack.Fixture.Builder do
  @moduledoc """
  A helper module to build fixture data from json files.
  """

  alias Haystack.Fixture

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      {from, paths} = Fixture.Builder.__extract__(__MODULE__, opts)

      for path <- paths do
        @external_resource Path.relative_to_cwd(path)
      end

      def __mix_recompile__? do
        unquote(from) |> Path.wildcard() |> Enum.sort() |> :erlang.md5() !=
          unquote(:erlang.md5(paths))
      end
    end
  end

  def __extract__(module, opts) do
    key = Keyword.fetch!(opts, :key)
    from = Keyword.fetch!(opts, :from)
    paths = from |> Path.wildcard() |> Enum.sort()

    entries =
      for path <- paths do
        path
        |> File.read!()
        |> Jason.decode!(keys: :atoms)
        |> Map.put(:id, path |> Path.rootname() |> Path.basename())
      end

    Module.put_attribute(module, key, entries)

    {from, paths}
  end
end
