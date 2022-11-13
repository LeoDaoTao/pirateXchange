defmodule PirateXchangeWeb.Middlewares.Errors do
  @behaviour Absinthe.Middleware

  @impl Absinthe.Middleware

  @spec call(Absinthe.Resolution.t(), any) :: Absinthe.Resolution.t()
  def call(resolution, _config) do
    %{resolution | errors: Enum.flat_map(resolution.errors, &process_error/1)}
  end

  defp process_error(%Ecto.Changeset{} = changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(fn {error, _opts} -> error end)
    |> Enum.map(fn {key, value} -> "#{key}: #{value}" end)
  end

  defp process_error(%ErrorMessage{message: message, code: code, details: details}) do
    [%{message: message, code: code, details: details}]
  end

  defp process_error(error), do: [error]
end
