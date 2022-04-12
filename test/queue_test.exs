defmodule QueueTest do
  use ExUnit.Case
  doctest Queue

  if Application.compile_env(:elixir_queue, :implement_enumerable, true) == true do
    describe "Queue implements Enumerable" do
      test "to_list" do
        assert [1, 2, 3, 4, 5] == Enum.to_list(Queue.new([1, 2, 3, 4, 5]))
      end

      test "map" do
        assert [3, 4, 5, 6, 7] == Enum.map(Queue.new([1, 2, 3, 4, 5]), &(&1 + 2))
      end

      test "sort" do
        assert [1, 2, 3, 4, 5] == Enum.sort(Queue.new([5, 3, 4, 1, 2]))
      end
    end
  else
    test "Queue does not implement Enumerable" do
      assert_raise Protocol.UndefinedError, fn ->
        Enum.to_list(Queue.new([1, 2, 3, 4, 5]))
      end
    end
  end

  if Application.compile_env(:elixir_queue, :implement_collectable, true) == true do
    def queues_are_equal(queue1, queue2) do
      # we do these weird comparisons because the underlying data structures are not the same
      # but they contain the same elements
      assert Queue.first(queue1) == Queue.first(queue2)
      assert Queue.last(queue1) == Queue.last(queue2)
      assert Queue.to_list(queue1) == Queue.to_list(queue2)
    end

    describe "Queue implements Collectable" do
      test "into new" do
        queue1 = Enum.into(1..5, Queue.new())
        queue2 = Queue.new([1, 2, 3, 4, 5])

        queues_are_equal(queue1, queue2)
      end

      test "into existing" do
        queue1 = Enum.into(5..8, Queue.new([1, 2, 3, 4]))
        queue2 = Queue.new([1, 2, 3, 4, 5, 6, 7, 8])

        queues_are_equal(queue1, queue2)
      end
    end
  else
    test "Queue does not implement Collectable" do
      assert_raise Protocol.UndefinedError, fn ->
        Enum.into([1, 2, 3], Queue.new())
      end
    end
  end
end
