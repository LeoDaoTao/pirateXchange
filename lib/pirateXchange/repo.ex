defmodule PirateXchange.Repo do
  use Ecto.Repo,
    otp_app: :pirateXchange,
    adapter: Ecto.Adapters.Postgres
end
