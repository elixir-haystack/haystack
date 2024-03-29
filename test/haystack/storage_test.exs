defmodule Haystack.StorageTest do
  use ExUnit.Case, async: true

  alias Haystack.Storage

  doctest Storage

  setup do
    Storage.Map.new()
    |> Storage.insert(:name, "Haystack")
    |> then(fn storage -> %{storage: storage} end)
  end

  describe "fetch/2" do
    test "fail to fetch", %{storage: storage} do
      {:error, error} = Storage.fetch(storage, :desc)

      assert %Storage.NotFoundError{} = error
    end

    test "should fetch", %{storage: storage} do
      assert {:ok, "Haystack"} == Storage.fetch(storage, :name)
    end
  end

  describe "fetch!/2" do
    test "fail to fetch", %{storage: storage} do
      assert_raise Storage.NotFoundError, fn ->
        Storage.fetch!(storage, :desc)
      end
    end

    test "should fetch", %{storage: storage} do
      assert "Haystack" == Storage.fetch!(storage, :name)
    end
  end

  describe "insert/3" do
    test "should insert", %{storage: storage} do
      storage = Storage.insert(storage, :desc, "Needle in a Haystack")

      assert "Needle in a Haystack" == Storage.fetch!(storage, :desc)
    end
  end

  describe "update/3" do
    test "fail to update", %{storage: storage} do
      {:error, error} = Storage.update(storage, :desc, &String.upcase/1)

      assert %Storage.NotFoundError{} = error
    end

    test "should update", %{storage: storage} do
      {:ok, storage} = Storage.update(storage, :name, &String.upcase/1)

      assert "HAYSTACK" == Storage.fetch!(storage, :name)
    end
  end

  describe "update/!3" do
    test "fail to update", %{storage: storage} do
      assert_raise Storage.NotFoundError, fn ->
        Storage.update!(storage, :desc, &String.upcase/1)
      end
    end

    test "should update", %{storage: storage} do
      storage = Storage.update!(storage, :name, &String.upcase/1)

      assert "HAYSTACK" == Storage.fetch!(storage, :name)
    end
  end

  describe "upsert/3" do
    test "should upsert", %{storage: storage} do
      desc = "Needle in a Haystack"

      storage = Storage.upsert(storage, :desc, desc, &String.upcase/1)

      assert desc == Storage.fetch!(storage, :desc)

      storage = Storage.upsert(storage, :desc, desc, &String.upcase/1)

      assert String.upcase(desc) == Storage.fetch!(storage, :desc)
    end
  end

  describe "delete/2" do
    test "should delete", %{storage: storage} do
      storage = Storage.delete(storage, :name)

      assert {:error, _} = Storage.fetch(storage, :name)
    end
  end

  describe "count/1" do
    test "should return count", %{storage: storage} do
      assert Storage.count(storage) == 1
    end
  end

  describe "serialize/1" do
    test "should serialize", %{storage: storage} do
      assert is_binary(Storage.serialize(storage))
    end
  end

  describe "deserialize/1" do
    test "should deserialize", %{storage: storage} do
      binary = Storage.Map.serialize(storage)

      assert %Storage.Map{} = Storage.deserialize(binary)
    end
  end
end
