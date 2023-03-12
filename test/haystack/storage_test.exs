defmodule Haystack.StorageTest do
  use ExUnit.Case, async: true

  alias Haystack.Storage

  doctest Storage

  setup do
    Storage.Memory.new()
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
      storage = Storage.insert(storage, :desc, "Haystack is...")

      assert "Haystack is..." == Storage.fetch!(storage, :desc)
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
      desc = "Haystack is..."

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

  describe "dump!/2" do
    @tag :tmp_dir
    test "should dump", %{storage: storage, tmp_dir: dir} do
      :ok = Storage.dump!(storage, Path.join(dir, "storage.haystack"))

      assert File.exists?(Path.join(dir, "storage.haystack"))
    end
  end
end
