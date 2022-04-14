defmodule Queue.Collection do
  @moduledoc """
  Wrapper around the queue that implements the Enumerable and Collectable protocol.

  This struct is for if you don't want the protocols enabled for tuples but still want to use the Enum module.

  ```elixir
  iex> [1,2,3,4] |> Queue.Collection.new() |> Enum.to_list()
  [1,2,3,4]
  iex> [1,2,3,4] |> Queue.new() |> Queue.Collection.new() |> Enum.to_list()
  [1,2,3,4]
  ```

  ```elixir
  iex> Enum.into(1..4, Queue.Collection.new([0]))
  {[4, 3, 2, 1], [0]} # Queue.new([0,1,2,3,4])
  ```
  """

  defstruct inner: Queue.new()

  def new() do
    %__MODULE__{}
  end

  def new(queue) do
    queue
    |> Queue.new()
    |> from()
  end

  defp from(queue) do
    %__MODULE__{inner: queue}
  end
end

defimpl Enumerable, for: Queue.Collection do
  require Queue

  def count(%{inner: queue}), do: {:ok, Queue.length(queue)}

  def member?(%{inner: queue}, value), do: {:ok, Queue.member?(queue, value)}

  def slice(_queue), do: {:error, __MODULE__}

  def reduce(_queue, {:halt, acc}, _fun), do: {:halted, acc}
  def reduce(queue, {:suspend, acc}, fun), do: {:suspended, acc, &reduce(queue, &1, fun)}
  def reduce(%{inner: queue}, {:cont, acc}, _fun) when Queue.is_empty(queue), do: {:done, acc}

  def reduce(%{inner: queue}, {:cont, acc}, fun) do
    {head, tail} = Queue.pop_front(queue)
    reduce(%Queue.Collection{inner: tail}, fun.(head, acc), fun)
  end
end

defimpl Collectable, for: Queue.Collection do
  def into(%{inner: queue}) do
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
