import Config

config :elixir_queue,
  implement_enumerable:
    System.get_env("QUEUE_TEST_ENUMERABLE", "true") |> String.to_existing_atom()

config :elixir_queue,
  implement_collectable:
    System.get_env("QUEUE_TEST_COLLECTABLE", "true") |> String.to_existing_atom()
