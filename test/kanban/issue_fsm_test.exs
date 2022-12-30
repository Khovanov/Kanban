defmodule Kanban.IssueFSMTest do
  use ExUnit.Case, async: true
  doctest Kanban.IssueFSM

  alias Kanban.Data.Issue
  alias Kanban.IssueFSM

  @sleep_test_ms 1

  setup do
    {:ok, pid} = IssueFSM.start_link(%Issue{state: "pending"})

    {:ok, pid: pid}
  end

  describe "start/1" do
    test "returns :ok and change issue state", %{pid: pid} do
      assert :ok == IssueFSM.start(pid)
      assert IssueFSM.state(pid) == "progress"
    end
  end

  describe "resolve/1" do
    setup %{pid: pid} do
      IssueFSM.start(pid)
    end

    test "returns :ok and change issue state", %{pid: pid} do
      assert :ok == IssueFSM.resolve(pid)
      assert IssueFSM.state(pid) == "resolved"
    end
  end

  describe "drop/1" do
    setup %{pid: pid} do
      IssueFSM.start(pid)
      IssueFSM.resolve(pid)
    end

    test "returns :ok and stop process", %{pid: pid} do
      assert :ok == IssueFSM.drop(pid)

      Process.sleep(@sleep_test_ms)

      assert Process.alive?(pid) == false
    end
  end

  describe "send wrong transition" do
    setup %{pid: pid} do
      IssueFSM.start(pid)
      IssueFSM.resolve(pid)
    end

    @tag :capture_log
    test "returns :ok but NOT change issue state", %{pid: pid} do
      assert :ok == IssueFSM.start(pid)
      assert IssueFSM.state(pid) == "resolved"
    end
  end
end
