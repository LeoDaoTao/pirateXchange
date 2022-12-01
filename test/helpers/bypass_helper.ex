defmodule PirateXchange.BypassHelper do
  def bypass_expect(response, bypass) do
    Bypass.expect(bypass, fn conn ->
      Plug.Conn.resp(conn, 200, response)
    end)
  end
end
