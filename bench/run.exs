Benchee.run(
  %{
    "new" => fn input -> Queue.new(input) end,
    "into" => fn input -> Enum.into(input, Queue.new()) end,
    "collection" => fn input -> Enum.into(input, Queue.ReverseCollection.new()) end,
    "reverse" => fn input -> Enum.into(input, Queue.Collection.new()) end,
    "new reverse" => fn input -> input |> Queue.new() |> Queue.reverse() end,
    "into reverse" => fn input -> Enum.into(input, Queue.new()) |> Queue.reverse() end,
  },
  inputs: %{
    "Small" => Enum.to_list(1..1_000),
    "Medium" => Enum.to_list(1..10_000),
    "Bigger" => Enum.to_list(1..100_000)
  }
)
