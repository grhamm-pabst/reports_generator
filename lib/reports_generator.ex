defmodule ReportsGenerator do
  alias ReportsGenerator.Parser

  @options ["foods", "users"]

  def build(filename) do
    filename
    |> Parser.parse_files()
    |> Enum.reduce(report_acc(filename), fn line, report ->
      sum_values(line, report)
    end)
  end

  def fetch_higher_cost(report, option) when option in @options,
    do: {:ok, Enum.max_by(report[option], fn {_id, value} -> value end)}

  def fetch_higher_cost(_report, _option), do: {:error, "Invalid option"}

  defp sum_values([id, food_name, price], %{"foods" => foods, "users" => users} = report) do
    users = Map.put(users, id, users[id] + price)
    foods = Map.put(foods, food_name, foods[food_name] + 1)

    %{report | "users" => users, "foods" => foods}
  end

  defp report_acc(filename) do
    users = Enum.into(1..get_max_user_id(filename), %{}, &{Integer.to_string(&1), 0})
    foods = Enum.into(get_food_names(filename), %{}, &{&1, 0})
    %{"users" => users, "foods" => foods}
  end

  defp get_max_user_id(filename) do
    filename
    |> Parser.parse_files()
    |> Enum.map(fn [id, _food_name, _price] -> String.to_integer(id) end)
    |> Enum.max()
  end

  defp get_food_names(filename) do
    filename
    |> Parser.parse_files()
    |> Enum.map(fn [_id, food_name, _price] -> food_name end)
    |> Enum.uniq()
  end
end
