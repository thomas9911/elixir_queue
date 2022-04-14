defmodule Queue.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_queue,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: [:dev], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:benchee, "~> 1.0", only: :dev}
    ]
  end

  defp aliases do
    [
      testing: ["a", "b"],
      a: &test_with_env_vars/1,
      b: &test_without_env_vars/1
    ]
  end

  defp test_without_env_vars(_args) do
    Mix.shell().cmd("MIX_ENV=test mix do compile --force, test --color")
  end

  defp test_with_env_vars(_args) do
    Mix.shell().cmd(
      "QUEUE_TEST_COLLECTABLE=false QUEUE_TEST_ENUMERABLE=false MIX_ENV=test mix do compile --force, test --color"
    )
  end
end
