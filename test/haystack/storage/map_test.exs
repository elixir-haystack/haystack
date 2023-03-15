defmodule Haystack.Storage.MapTest do
  use ExUnit.Case, async: true

  alias Haystack.Storage

  doctest Storage.Map

  setup do
    %{storage: Storage.Map.new()}
  end

  describe "fetch/2" do
    test "fail to fetch", %{storage: storage} do
      {:error, error} = Storage.Map.fetch(storage, :desc)

      assert %Storage.NotFoundError{} = error
    end

    test "should fetch", %{storage: storage} do
      storage = Storage.Map.insert(storage, :name, "Haystack")

      assert {:ok, "Haystack"} == Storage.Map.fetch(storage, :name)
    end
  end

  describe "fetch!/2" do
    test "fail to fetch", %{storage: storage} do
      assert_raise Storage.NotFoundError, fn ->
        Storage.Map.fetch!(storage, :desc)
      end
    end

    test "should fetch", %{storage: storage} do
      storage = Storage.Map.insert(storage, :name, "Haystack")

      assert "Haystack" == Storage.Map.fetch!(storage, :name)
    end
  end

  describe "insert/3" do
    test "should insert", %{storage: storage} do
      storage = Storage.Map.insert(storage, :name, "Haystack")

      assert "Haystack" == Storage.Map.fetch!(storage, :name)
    end
  end

  describe "update/3" do
    test "fail to update", %{storage: storage} do
      {:error, error} = Storage.Map.update(storage, :name, &String.upcase/1)

      assert %Storage.NotFoundError{} = error
    end

    test "should update", %{storage: storage} do
      storage = Storage.Map.insert(storage, :name, "Haystack")

      {:ok, storage} = Storage.Map.update(storage, :name, &String.upcase/1)

      assert "HAYSTACK" == Storage.Map.fetch!(storage, :name)
    end
  end

  describe "update/!3" do
    test "fail to update", %{storage: storage} do
      assert_raise Storage.NotFoundError, fn ->
        Storage.Map.update!(storage, :desc, &String.upcase/1)
      end
    end

    test "should update", %{storage: storage} do
      storage = Storage.Map.insert(storage, :name, "Haystack")
      storage = Storage.Map.update!(storage, :name, &String.upcase/1)

      assert "HAYSTACK" == Storage.Map.fetch!(storage, :name)
    end
  end

  describe "upsert/3" do
    test "should upsert", %{storage: storage} do
      storage = Storage.Map.upsert(storage, :name, "haystack", &String.upcase/1)

      assert "haystack" == Storage.Map.fetch!(storage, :name)

      storage = Storage.Map.upsert(storage, :name, "haystack", &String.upcase/1)

      assert "HAYSTACK" == Storage.Map.fetch!(storage, :name)
    end
  end

  describe "delete/2" do
    test "should delete", %{storage: storage} do
      storage = Storage.Map.insert(storage, :name, "Haystack")
      storage = Storage.Map.delete(storage, :name)

      assert {:error, _} = Storage.Map.fetch(storage, :name)
    end
  end

  describe "count/1" do
    test "should return count", %{storage: storage} do
      storage = Storage.Map.insert(storage, :name, "Haystack")

      assert Storage.Map.count(storage) == 1
    end
  end

  describe "serialize/2" do
    test "should serialize", %{storage: storage} do
      storage = Storage.Map.insert(storage, :name, "Haystack")

      assert is_binary(Storage.Map.serialize(storage))
    end
  end
end
