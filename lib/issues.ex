defmodule Issues do
  @default_count 4

  def main(argv) do
    run(argv)
  end

  def run(argv) do
    argv
      |> parse_args
      |> process
  end

  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [ help: :boolean], aliases: [h: :help])

    case parse do
      {[ help: true ], _ , _}          -> :help
      {_, [ user, project, count ], _} -> {user, project, String.to_integer(count)}
      {_, [ user, project], _}         -> {user, project, @default_count}
      _ -> :help
    end
  end

  def process(:help) do
    IO.puts """
    usage: issues <user> <project> [ count | #{@default_count} ]
    """

    System.halt(0)
  end

  def process({user, project, count }) do
    fetch(user, project)
      |> decode_response
      |> convert_to_list_of_maps
      |> sort_into_acending_order
      |> Enum.take(count)
  end

  def fetch(user, project) do
    issues_url(user, project)
      |> HTTPoison.get([{"User-agent", "Elixir Application"}])
      |> handle_response
  end

  def issues_url(user, project) do
    "https://api.github.com/repos/#{user}/#{project}/issues"
  end

  def handle_response({ :ok, %{status_code: 200, body: body}}) do
    {:ok, Poison.Parser.parse!(body)}
  end

  def handle_response({ ___, %{status_code: ___, body: body}}) do
    {:error, Poison.Parser.parse!(body)}
  end

  def decode_response({:ok, body}) do
    body
  end

  def decode_response({:error, error}) do
    {_, message} = List.keyfind(error, "message", 0)
    IO.puts "Error fetching from Github: #{message}"
    System.halt(2)
  end

  def convert_to_list_of_maps(list) do
    list
      |> Enum.map(&Enum.into(&1, Map.new))
  end

  def sort_into_acending_order(list) do
    list
      |> Enum.sort(fn (e0, e1) -> e0["created_at"] <= e1["created_at"] end)
  end

end
