defmodule Haystack.Storage.ETS do
  @moduledoc """
  An ETS implementation of the storage behaviour.
  """

  use GenServer

  alias Haystack.Storage

  @behaviour Haystack.Storage

  @type t :: %__MODULE__{
          name: GenServer.name(),
          table: atom,
          data: list({term, term})
        }

  @enforce_keys ~w{name table data}a

  defstruct @enforce_keys

  # Behaviour: Haystack.Storage

  @doc """
  Create a new storage.
  """
  @impl Haystack.Storage
  def new(opts \\ []) do
    opts =
      opts
      |> Keyword.put(:data, [])
      |> Keyword.put_new(:name, :haystack)
      |> Keyword.put_new(:table, :haystack)

    struct(__MODULE__, opts)
  end

  @doc """
  Fetch an item from storage.
  """
  @impl Haystack.Storage
  def fetch(storage, k) do
    case :ets.lookup(storage.table, k) do
      [] -> {:error, %Storage.NotFoundError{message: "Not found"}}
      [{^k, v}] -> {:ok, v}
    end
  end

  @doc """
  Fetch an item from storage.
  """
  @impl Haystack.Storage
  def fetch!(storage, k) do
    case fetch(storage, k) do
      {:ok, v} -> v
      {:error, error} -> raise error
    end
  end

  @doc """
  Insert an item into storage.
  """
  @impl Haystack.Storage
  def insert(storage, k, v),
    do: GenServer.call(storage.name, {:insert, {k, v}})

  @doc """
  Update an item in storage.
  """
  @impl Haystack.Storage
  def update(storage, k, f) do
    with {:ok, v} <- fetch(storage, k) do
      {:ok, GenServer.call(storage.name, {:insert, {k, f.(v)}})}
    end
  end

  @doc """
  Update an item in storage.
  """
  @impl Haystack.Storage
  def update!(storage, k, f) do
    case update(storage, k, f) do
      {:ok, storage} -> storage
      {:error, error} -> raise error
    end
  end

  @doc """
  Upsert an item in storage.
  """
  @impl Haystack.Storage
  def upsert(storage, k, v, f) do
    case update(storage, k, f) do
      {:ok, storage} -> storage
      {:error, _} -> insert(storage, k, v)
    end
  end

  @doc """
  Delete an item from storage.
  """
  @impl Haystack.Storage
  def delete(storage, k),
    do: GenServer.call(storage.name, {:delete, k})

  @doc """
  Return the count of items in storage.
  """
  @impl Haystack.Storage
  def count(storage) do
    info = :ets.info(storage.table)

    Keyword.fetch!(info, :size)
  end

  @doc """
  Serialize the storage.
  """
  @impl Haystack.Storage
  def serialize(storage),
    do: GenServer.call(storage.name, :serialize)

  # Behaviour: GenServer

  def start_link(opts) do
    {storage, opts} = Keyword.pop!(opts, :storage)

    GenServer.start_link(__MODULE__, storage, [name: storage.name] ++ opts)
  end

  @impl true
  def init(storage) do
    :ets.new(storage.table, [:set, :protected, :named_table])

    {data, storage} = Map.get_and_update!(storage, :data, &{&1, []})

    {:ok, storage, {:continue, data}}
  end

  @impl true
  def handle_call({:insert, {k, v}}, _from, storage) do
    true = :ets.insert(storage.table, {k, v})

    {:reply, storage, storage}
  end

  def handle_call({:delete, k}, _from, storage) do
    true = :ets.delete(storage.table, k)

    {:reply, storage, storage}
  end

  def handle_call(:serialize, _from, storage) do
    data = :ets.tab2list(storage.table)

    {:reply, :erlang.term_to_binary(%{storage | data: data}), storage}
  end

  @impl true
  def handle_continue([], storage), do: {:noreply, storage}

  def handle_continue(data, storage) do
    Enum.each(data, &:ets.insert(storage.table, &1))

    {:noreply, storage}
  end
end
