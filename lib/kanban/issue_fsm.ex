defmodule Kanban.IssueFSM do
  @moduledoc """
  Issue FSM implementation

  ## Examples

      # Cancel branch
      iex> {:ok, pid} = Kanban.IssueFSM.start_link(%Kanban.Data.Issue{state: "pending"})
      iex> Kanban.IssueFSM.cancel(pid)
      :ok
      iex> Kanban.IssueFSM.state(pid)
      "canceled"
      iex> Kanban.IssueFSM.drop(pid)
      :ok

      # Resolve branch
      iex> {:ok, pid} = Kanban.IssueFSM.start_link(%Kanban.Data.Issue{state: "pending"})
      iex> Kanban.IssueFSM.start(pid)
      :ok
      iex> Kanban.IssueFSM.state(pid)
      "progress"
      iex> Kanban.IssueFSM.resolve(pid)
      :ok
      iex> Kanban.IssueFSM.state(pid)
      "resolved"
      iex> Kanban.IssueFSM.drop(pid)
      :ok

  """

  use GenServer

  alias Kanban.Data.Issue

  require Logger

  @doc """
  Start and link process.
  """
  def start_link(%Issue{state: "pending"} = issue) do
    GenServer.start_link(__MODULE__, issue)
  end

  @doc """
  cancel issue
  """
  def cancel(pid) do
    GenServer.cast(pid, {:transition, :cancel})
  end

  @doc """
  start issue
  """
  def start(pid) do
    GenServer.cast(pid, {:transition, :start})
  end

  @doc """
  resolve issue
  """
  def resolve(pid) do
    GenServer.cast(pid, {:transition, :resolve})
  end

  @doc """
  drop issue - stop process
  """
  def drop(pid) do
    GenServer.cast(pid, {:transition, :drop})
  end

  @doc """
  show issue state
  """
  def state(pid) do
    GenServer.call(pid, :state)
  end

  @doc """
  Callback function for GenServer.init/1
  """
  @impl GenServer
  def init(issue) do
    Logger.info(pid: self(), state: issue.state)

    {:ok, issue}
  end

  @doc """
  Callback function for GenServer.handle_cast/2

  send transition into issue
  """
  @impl GenServer
  def handle_cast({:transition, :cancel}, %Issue{state: "pending"} = issue) do
    # Save to external storage
    Logger.info(pid: self(), state: "canceled")
    {:noreply, %Issue{issue | state: "canceled"}}
  end

  def handle_cast({:transition, :start}, %Issue{state: "pending"} = issue) do
    # Save to external storage
    Logger.info(pid: self(), state: "progress")
    {:noreply, %Issue{issue | state: "progress"}}
  end

  def handle_cast({:transition, :resolve}, %Issue{state: "progress"} = issue) do
    # Save to external storage
    Logger.info(pid: self(), state: "resolved")
    {:noreply, %Issue{issue | state: "resolved"}}
  end

  def handle_cast({:transition, :drop}, %Issue{state: state} = issue)
      when state in ["canceled", "resolved"] do
    # Remove from external storage
    Logger.info(pid: self(), msg: "Issue dropped")
    {:stop, :normal, issue}
  end

  def handle_cast({:transition, transition}, %Issue{state: state} = issue) do
    Logger.warn(pid: self(), error: {:not_allowed, transition, state})
    {:noreply, issue}
  end

  @doc """
  Callback function for GenServer.handle_call/3

  show issue state
  """
  @impl GenServer
  def handle_call(:state, _from, %Issue{state: state} = issue) do
    {:reply, state, issue}
  end
end
