defmodule Haystack.Index.Field do
  @moduledoc """
  A module for index fields
  """

  @enforce_keys ~w{k path}a

  defstruct @enforce_keys

  @type t :: %__MODULE__{
          k: k,
          path: list(String.t())
        }
  @type k :: String.t()

  @doc """
  Create a new field.

  ## Examples

    iex> Index.Field.new("name")
    %Index.Field{k: "name", path: ["name"]}

    iex> Index.Field.new("address.postcode")
    %Index.Field(k: "address.postcode", path: ["address", "postcode"])

  """
  def new(k) do
    path = String.split(k, ".")

    struct(__MODULE__, k: k, path: path)
  end
end
