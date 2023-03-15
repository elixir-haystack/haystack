defmodule Haystack.Storage.ETSTest do
  use ExUnit.Case, async: true

  alias Haystack.Storage

  doctest Storage.ETS

  setup %{test: test} do
    storage = Storage.ETS.new(name: test, table: test)

    start_supervised!({Storage.ETS, storage: storage})

    %{storage: storage}
  end

  describe "fetch/2" do
    test "fail to fetch", %{storage: storage} do
      {:error, error} = Storage.ETS.fetch(storage, :desc)

      assert %Storage.NotFoundError{} = error
    end

    test "should fetch", %{storage: storage} do
      storage = Storage.ETS.insert(storage, :name, "Haystack")

      assert {:ok, "Haystack"} == Storage.ETS.fetch(storage, :name)
    end
  end

  describe "fetch!/2" do
    test "fail to fetch", %{storage: storage} do
      assert_raise Storage.NotFoundError, fn ->
        Storage.ETS.fetch!(storage, :name)
      end
    end

    test "should fetch", %{storage: storage} do
      storage = Storage.ETS.insert(storage, :name, "Haystack")

      assert "Haystack" == Storage.ETS.fetch!(storage, :name)
    end
  end

  describe "insert/3" do
    test "should insert", %{storage: storage} do
      storage = Storage.ETS.insert(storage, :name, "Haystack")

      assert "Haystack" == Storage.ETS.fetch!(storage, :name)
    end
  end

  describe "update/3" do
    test "fail to update", %{storage: storage} do
      {:error, error} = Storage.ETS.update(storage, :name, &String.upcase/1)

      assert %Storage.NotFoundError{} = error
    end

    test "should update", %{storage: storage} do
      storage = Storage.ETS.insert(storage, :name, "Haystack")

      {:ok, storage} = Storage.ETS.update(storage, :name, &String.upcase/1)

      assert "HAYSTACK" == Storage.ETS.fetch!(storage, :name)
    end
  end

  describe "update/!3" do
    test "fail to update", %{storage: storage} do
      assert_raise Storage.NotFoundError, fn ->
        Storage.ETS.update!(storage, :name, &String.upcase/1)
      end
    end

    test "should update", %{storage: storage} do
      storage = Storage.ETS.insert(storage, :name, "Haystack")
      storage = Storage.ETS.update!(storage, :name, &String.upcase/1)

      assert "HAYSTACK" == Storage.ETS.fetch!(storage, :name)
    end
  end

  describe "upsert/3" do
    test "should upsert", %{storage: storage} do
      storage = Storage.ETS.upsert(storage, :name, "haystack", &String.upcase/1)

      assert "haystack" == Storage.ETS.fetch!(storage, :name)

      storage = Storage.ETS.upsert(storage, :name, "haystack", &String.upcase/1)

      assert "HAYSTACK" == Storage.ETS.fetch!(storage, :name)
    end
  end

  describe "delete/2" do
    test "should delete", %{storage: storage} do
      storage = Storage.ETS.insert(storage, :name, "Haystack")
      storage = Storage.ETS.delete(storage, :name)

      assert {:error, _} = Storage.ETS.fetch(storage, :name)
    end
  end

  describe "count/1" do
    test "should return count", %{storage: storage} do
      storage = Storage.ETS.insert(storage, :name, "Haystack")

      assert Storage.ETS.count(storage) == 1
    end
  end

  describe "serialize/2" do
    test "should serialize", %{storage: storage} do
      storage = Storage.ETS.insert(storage, :name, "Haystack")

      assert is_binary(Storage.ETS.serialize(storage))
    end
  end

  describe "misc" do
    test "should restore", %{storage: storage} do
      storage = Storage.ETS.insert(storage, :name, "Haystack")
      storage = Storage.ETS.serialize(storage) |> Storage.deserialize()

      :ok = stop_supervised!(Storage.ETS)

      start_supervised!({Storage.ETS, storage: storage})

      assert "Haystack" == Storage.ETS.fetch!(storage, :name)
    end
  end
end
