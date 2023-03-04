defmodule Haystack.Storage.MemoryTest do
  use ExUnit.Case, async: true

  alias Haystack.Storage

  doctest Haystack.Storage.Memory

  setup do
    %{s: Storage.Memory.new() |> Storage.Memory.insert(:a, "a")}
  end

  describe "new/1" do
    assert %Storage.Memory{} = Storage.Memory.new()
  end

  describe "fetch/2" do
    test "fail to fetch", %{s: s} do
      assert {:error, %Storage.NotFoundError{}} = Storage.Memory.fetch(s, :b)
    end

    test "should fetch", %{s: s} do
      assert {:ok, "a"} == Storage.Memory.fetch(s, :a)
    end
  end

  describe "fetch!/2" do
    test "fail to fetch", %{s: s} do
      assert_raise Storage.NotFoundError, fn ->
        Storage.Memory.fetch!(s, :b)
      end
    end

    test "should fetch", %{s: s} do
      assert "a" == Storage.Memory.fetch!(s, :a)
    end
  end

  describe "insert/3" do
    test "should insert", %{s: s} do
      s = Storage.Memory.insert(s, :b, "b")

      assert "b" == Storage.Memory.fetch!(s, :b)
    end
  end

  describe "update/3" do
    test "fail to update", %{s: s} do
      {:error, error} = Storage.Memory.update(s, :b, &(&1 <> &1))

      assert %Storage.NotFoundError{} = error
    end

    test "should update", %{s: s} do
      {:ok, s} = Storage.Memory.update(s, :a, &(&1 <> &1))

      assert "aa" == Storage.Memory.fetch!(s, :a)
    end
  end

  describe "update/!3" do
    test "fail to update", %{s: s} do
      assert_raise Storage.NotFoundError, fn ->
        Storage.Memory.update!(s, :b, &(&1 <> &1))
      end
    end

    test "should update", %{s: s} do
      s = Storage.Memory.update!(s, :a, &(&1 <> &1))

      assert "aa" == Storage.Memory.fetch!(s, :a)
    end
  end

  describe "upsert/3" do
    test "should upsert insert", %{s: s} do
      s = Storage.Memory.upsert(s, :b, "b", fn _ -> "b" end)

      assert "b" == Storage.Memory.fetch!(s, :b)
    end

    test "should upsert update", %{s: s} do
      s = Storage.Memory.upsert(s, :a, "b", fn _ -> "b" end)

      assert "b" == Storage.Memory.fetch!(s, :a)
    end
  end

  describe "delete/2" do
    test "should delete", %{s: s} do
      s = Storage.Memory.delete(s, :a)

      assert {:error, _} = Storage.Memory.fetch(s, :a)
    end
  end

  describe "dump!/2" do
    @tag :tmp_dir
    test "should dump", %{s: s, tmp_dir: dir} do
      :ok = Storage.Memory.dump!(s, Path.join(dir, "storage.memoria"))

      assert File.exists?(Path.join(dir, "storage.memoria"))
    end
  end

  describe "load!/2" do
    @tag :tmp_dir
    test "fail to load", %{tmp_dir: dir} do
      assert_raise File.Error, fn ->
        Storage.Memory.load!(Path.join(dir, "storage.memoria"))
      end
    end

    @tag :tmp_dir
    test "should load", %{s: s, tmp_dir: dir} do
      Storage.Memory.dump!(s, Path.join(dir, "storage.memoria"))

      s = Storage.Memory.load!(Path.join(dir, "storage.memoria"))

      assert "a" == Storage.Memory.fetch!(s, :a)
    end
  end
end
