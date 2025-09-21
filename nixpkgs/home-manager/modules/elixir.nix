{
  config,
  pkgs,
  expert ? null,
  ...
}: {
  home.file.".iex.exs".text = ''
    defmodule IExHelpers do
      @doc """
      Copies the given term to the clipboard.

      If the term is binary, it is copied directly. Otherwise, the term is inspected
      with no limit and pretty formatting, and then copied.

      ## Examples

          iex> User |> Repo.get!(user_id) |> IExHelpers.copy
          :ok

      """
      def copy(term) do
        text =
          if is_binary(term) do
            term
          else
            inspect(term, limit: :infinity, pretty: true)
          end

        port = Port.open({:spawn, "pbcopy"}, [])
        true = Port.command(port, text)
        true = Port.close(port)

        :ok
      end
    end

    defmodule Util do
      def atom_status do
        limit = :erlang.system_info(:atom_limit)
        count = :erlang.system_info(:atom_count)

        IO.puts("Currently using #{count} / #{limit} atoms")
      end

      def cls, do: IO.puts("\ec")

      def recompile, do: IEx.Helpers.recompile()

      def raw(any, label \\ "iex") do
        IO.inspect(any,
          label: label,
          pretty: true,
          limit: :infinity,
          structs: false,
          syntax_colors: [
            number: :yellow,
            atom: :cyan,
            string: :green,
            nil: :magenta,
            boolean: :magenta
          ],
          width: 0
        )
      end

      def help do
        __MODULE__.__info__(:functions)
      end
    end

    defmodule :_exit do
      defdelegate exit(), to: System, as: :halt
      defdelegate q(), to: System, as: :stop
    end

    defmodule :_restart do
      defdelegate restart(), to: System, as: :restart
    end

    defmodule :_util do
      defdelegate cls(), to: Util, as: :cls
      defdelegate raw(any), to: Util, as: :raw
      defdelegate r(), to: Util, as: :recompile
    end

    import :_exit
    import :_restart
    import :_util

    Application.put_env(:elixir, :ansi_enabled, true)
  '';
}
