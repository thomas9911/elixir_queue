defmodule Queue do
  @moduledoc """
  Elixir wrapper around erlang :queue

  Optionally also implements the Enumerable and Collectable protocols (turned on by default). This can be turned of by setting 
  ```
  config :queue, 
    implement_enumerable: false
    implement_collectable: false
  ```
  in the config. 
  I made these optional because this implement these protocols for `Tuple`'s and if you have your own implementation of these protocols on `Tuple`s there is a problem.

  """

  @type t :: :queue.queue()

  defguard is_empty(queue) when queue == {[], []}

  defdelegate new, to: :queue

  @spec new() :: Queue.t()
  @spec new(Enumerable.t()) :: Queue.t()
  @spec new(Enumerable.t(), (any -> any)) :: Queue.t()
  @doc """
  see `new/0` `new/2`
  """
  def new(enum) do
    enum
    |> Enum.to_list()
    |> Queue.from_list()
  end

  @doc """
  Create new queue object. Optionally with an `Enumerable.t()` and function.

  ```elixir
  iex> Queue.new([1,2,3,4])
  Queue.from_list([1,2,3,4])
  iex> Queue.new(1..4)
  Queue.from_list([1,2,3,4])
  iex> Queue.new([1,2,3,4], & &1*2)
  Queue.from_list([2,4,6,8])
  ```
  """
  def new(enum, mapper) do
    enum
    |> Enum.map(mapper)
    |> Queue.from_list()
  end

  defdelegate from_list(list), to: :queue
  defdelegate queue?(queue), to: :queue, as: :is_queue
  defdelegate empty?(queue), to: :queue, as: :is_empty
  defdelegate to_list(queue), to: :queue
  defdelegate length(queue), to: :queue, as: :len
  defdelegate reverse(queue), to: :queue
  defdelegate join(queue1, queue2), to: :queue

  defdelegate insert(queue, item), to: Queue, as: :insert_front

  @doc """
  Insert an item at the front of the queue

  ```elixir
  iex> Queue.new([4]) |> Queue.insert_front(2)
  Queue.from_list([2,4])
  ```
  """
  def insert_front(queue, item) do
    :queue.in_r(item, queue)
  end

  @doc """
  Insert an item at the back of the queue

  ```elixir
  iex> Queue.new([2]) |> Queue.insert_back(4)
  Queue.from_list([2,4])
  ```
  """
  def insert_back(queue, item) do
    :queue.in(item, queue)
  end

  @doc """
  Remove the first item and leave the rest. If the queue is empty return the default argument.

  ```elixir
  iex> Queue.new([2, 4, 6]) |> Queue.pop_front()
  {2, Queue.from_list([4, 6])}

  iex> Queue.new() |> Queue.pop_front()
  {nil, Queue.new()}

  iex> Queue.new() |> Queue.pop_front(:default)
  {:default, Queue.new()}
  ```
  """
  def pop_front(queue, default \\ nil) do
    case :queue.out(queue) do
      {:empty, queue} -> {default, queue}
      {{:value, value}, queue} -> {value, queue}
    end
  end

  @doc """
  Remove the last item and leave the rest. If the queue is empty return the default argument.

  ```elixir
  iex> Queue.new([2, 4, 6]) |> Queue.pop_back()
  {6, Queue.from_list([2, 4])}

  iex> Queue.new() |> Queue.pop_back()
  {nil, Queue.new()}

  iex> Queue.new() |> Queue.pop_back(:default)
  {:default, Queue.new()}
  ```
  """
  def pop_back(queue, default \\ nil) do
    case :queue.out_r(queue) do
      {:empty, queue} -> {default, queue}
      {{:value, value}, queue} -> {value, queue}
    end
  end

  @doc """
  Remove the first argument from the queue.

  ```elixir
  iex> Queue.new([2, 4, 6]) |> Queue.remove_front()
  Queue.from_list([4, 6])
  iex> Queue.new() |> Queue.remove_front()
  Queue.new()
  ```
  """
  def remove_front(queue) when is_empty(queue), do: queue

  def remove_front(queue) do
    :queue.drop(queue)
  end

  @doc """
  Remove the last argument from the queue.

  ```elixir
  iex> Queue.new([2, 4, 6]) |> Queue.remove_back()
  Queue.from_list([2, 4])
  iex> Queue.new() |> Queue.remove_back()
  Queue.new()
  ```
  """
  def remove_back(queue) when is_empty(queue), do: queue

  def remove_back(queue) do
    :queue.drop_r(queue)
  end

  @doc """
  Get the first item in the queue

  ```elixir
  iex> Queue.new([1,2,3,4]) |> Queue.first()
  1
  iex> Queue.new() |> Queue.first()
  nil
  ```
  """
  def first(queue) when is_empty(queue), do: nil

  def first(queue) do
    :queue.get(queue)
  end

  @doc """
  Get the last item in the queue

  ```elixir
  iex> Queue.new([1,2,3,4]) |> Queue.last()
  4
  iex> Queue.new() |> Queue.last()
  nil
  ```
  """
  def last(queue) when is_empty(queue), do: nil

  def last(queue) do
    :queue.get_r(queue)
  end

  @doc """
  split the queue into two at the n index.

  iex> Queue.new([1,2,3,4,5,6]) |> Queue.split_at(4)
  {Queue.new([1,2,3,4]), Queue.new([5,6])}
  iex> Queue.new(0..5) |> Queue.split_at(4)
  {Queue.new([0,1,2,3]), Queue.new([4,5])}
  """
  def split_at(queue, n) do
    :queue.split(n, queue)
  end

  @doc """
  Check if the item is a member of the queue, or if the item is in the queue.

  iex> Queue.new([1,2,3,4,5,6]) |> Queue.member?(2)
  true
  iex> Queue.new([1,2,3,4,5,6]) |> Queue.member?(99)
  false
  """
  def member?(queue, item) do
    :queue.member(item, queue)
  end
end

if Application.compile_env(:queue, :implement_enumerable, true) == true do
  defimpl Enumerable, for: Tuple do
    require Queue

    def count(queue), do: {:ok, Queue.length(queue)}

    def member?(queue, value), do: {:ok, Queue.member?(queue, value)}

    def slice(_queue), do: {:error, __MODULE__}

    def reduce(_queue, {:halt, acc}, _fun), do: {:halted, acc}
    def reduce(queue, {:suspend, acc}, fun), do: {:suspended, acc, &reduce(queue, &1, fun)}
    def reduce(queue, {:cont, acc}, _fun) when Queue.is_empty(queue), do: {:done, acc}

    def reduce(queue, {:cont, acc}, fun) do
      {head, tail} = Queue.pop_front(queue)
      reduce(tail, fun.(head, acc), fun)
    end
  end
end

if Application.compile_env(:queue, :implement_collectable, true) == true do
  defimpl Collectable, for: Tuple do
    def into(queue) do
      collector_fun = fn
        acc, {:cont, elem} ->
          Queue.insert_back(acc, elem)

        acc, :done ->
          acc

        _acc, :halt ->
          :ok
      end

      {queue, collector_fun}
    end
  end
end
