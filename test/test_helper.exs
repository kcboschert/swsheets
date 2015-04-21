defmodule EdgeBuilder.Test do
  use ExUnit.CaseTemplate

  using do
    quote do
      use ExSpec
    end
  end

  setup do
    Ecto.Adapters.SQL.restart_test_transaction(EdgeBuilder.Repo)
    :ok
  end

  setup_all do
    Ecto.Adapters.SQL.begin_test_transaction(EdgeBuilder.Repo, [])
    on_exit fn -> Ecto.Adapters.SQL.rollback_test_transaction(EdgeBuilder.Repo, []) end
    :ok
  end
end

defmodule EdgeBuilder.ControllerTest do
  use ExUnit.CaseTemplate

  using do
    quote do
      use EdgeBuilder.Test
      use Plug.Test

      def request(verb, path, params \\ %{}) do
        conn(verb, path, params)
          |> put_private(:plug_skip_csrf_protection, true)
          |> EdgeBuilder.Endpoint.call([])
      end

      def is_redirect_to?(conn, path) do
        Enum.member?(conn.resp_headers, {"Location", path}) 
      end
    end
  end
end

Enum.each(Path.wildcard("test/helpers/**/*.exs"), &Code.load_file/1)
Enum.each(Path.wildcard("test/fixtures/**/*.exs"), &Code.load_file/1)

ExUnit.start
