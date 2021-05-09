defmodule ReportsGeneratorTest do
  use ExUnit.Case

  describe "build/1" do
    test "builds the report" do
      file_name = "report_test.csv"

      response = ReportsGenerator.build(file_name)

      expected_response = %{
        "foods" => %{
          "açaí" => 1,
          "churrasco" => 2,
          "esfirra" => 3,
          "hambúrguer" => 2,
          "pizza" => 2
        },
        "users" => %{
          "1" => 48,
          "10" => 36,
          "2" => 45,
          "3" => 31,
          "4" => 42,
          "5" => 49,
          "6" => 18,
          "7" => 27,
          "8" => 25,
          "9" => 24
        }
      }

      assert response == expected_response
    end
  end

  describe "fetch_higher_cost/2" do
    test "when the option is 'users' returns the user who expent most" do
      response =
        "report_test.csv"
        |> ReportsGenerator.build()
        |> ReportsGenerator.fetch_higher_cost("users")

      expected_response = {:ok, {"5", 49}}
      assert response == expected_response
    end

    test "when the option is 'foods' returns the food most wanted" do
      response =
        "report_test.csv"
        |> ReportsGenerator.build()
        |> ReportsGenerator.fetch_higher_cost("foods")

      expected_response = {:ok, {"esfirra", 3}}
      assert response == expected_response
    end

    test "when receive an invalid option" do
      response =
        "report_test.csv"
        |> ReportsGenerator.build()
        |> ReportsGenerator.fetch_higher_cost("bla")

      expected_response = {:error, "Invalid option"}
      assert response == expected_response
    end
  end
end
