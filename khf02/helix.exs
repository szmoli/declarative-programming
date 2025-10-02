defmodule Khf2 do
  @moduledoc """
  Számtekercs kiterítése
  @author "Szmoleniczki Ákos <szmoleniczki.akos@edu.bme.hu>"
  @date   "2025-10-xx"
  """

  # Alapadatok
  # tábla mérete (0 < n)
  @type size() :: integer()
  # ciklus hossza (0 < m <= n)
  @type cycle() :: integer()
  # mező értéke (0 < v <= m vagy "")
  @type value() :: integer()

  # Mezőkoordináták
  # sor száma (1-től n-ig)
  @type row() :: integer()
  # oszlop száma (1-től n-ig)
  @type col() :: integer()
  # mező koordinátái
  @type field() :: {row(), col()}

  # Feladványleírók
  # mező és értéke
  @type field_value() :: {field(), value()}
  # mező és opcionális értéke
  @type field_opt_value() :: {field(), value() | nil}

  # 1. elem: méret, 2. elem: ciklushossz,
  @type list_desc() :: [String.t()]
  # többi elem esetleg: mezők és értékük

  @spec helix(ps :: list_desc()) :: gs :: [field_opt_value()]
  # A ps szöveges feladványleíró-lista szerinti számtekercs kiterített listája gs
  # Csak N és M adott
  def helix([size_str | [_cycle_str]]) do
    size = size_str |> String.trim() |> String.to_integer()
    # cycle = cycle_str |> String.trim() |> String.to_integer()
    helix(1, size, 1, size, %{}, [])
  end

  # N és M mellett valahány mező értéke is adott
  def helix([size_str | [_cycle_str | field_value_strs]]) do
    size = size_str |> String.trim() |> String.to_integer()
    # cycle = cycle_str |> String.trim() |> String.to_integer()
    # IO.inspect({size, cycle})

    # Bemenet: ["  x1  y1 v1 ", " x2     y2 v2", ...]
    # Kell: %{{x, y} => v}
    # Map-hez kell: [{{x, y}, v}, ...]
    field_values =
      field_value_strs
      |> Enum.map(&String.split/1)
      |> Enum.map(fn [row, col, val] ->
        {{String.to_integer(row), String.to_integer(col)}, String.to_integer(val)}
      end)
      |> Map.new()

    # IO.inspect(field_values)
    helix(1, size, 1, size, field_values, [])
  end

  @spec helix(top :: integer(), bottom :: integer(), left :: integer(), right :: integer(), field_values :: %{field_value() => integer()}, acc :: [field_opt_value()]) :: [field_opt_value()]
  # Iteratívan bejárjuk a mátrixot a külső rétegtől befelé
  defp helix(top, bottom, left, right, field_values, acc) when top <= bottom and left <= right do
    # IO.inspect({top, bottom, left, right, acc})

    acc =
      # if left != right do
        left..right
        |> Enum.reduce(acc, fn col, acc ->
          [{{top, col}, Map.get(field_values, {top, col})} | acc]
        end)
      # else
      #   acc
      # end

    # IO.puts("left -> right:")
    # IO.inspect(acc)

    acc =
      # if top != bottom do
        (top + 1)..bottom
        |> Enum.reduce(acc, fn row, acc ->
          [{{row, right}, Map.get(field_values, {row, right})} | acc]
        end)
      # else
      #   acc
      # end

    # IO.puts("top -> bottom:")
    # IO.inspect(acc)

    acc =
      # if right != left do
        (right - 1)..left
        |> Enum.reduce(acc, fn col, acc ->
          # IO.inspect({{bottom, col}, Map.get(field_values, {bottom, col})})
          [{{bottom, col}, Map.get(field_values, {bottom, col})} | acc]
        end)
      # else
      #   acc
      # end

    # IO.puts("left <- right:")
    # IO.inspect(acc)

    acc =
      # if bottom != top do
        (bottom - 1)..(top + 1)
        |> Enum.reduce(acc, fn row, acc ->
          # IO.inspect({{row, left}, Map.get(field_values, {row, left})})
          [{{row, left}, Map.get(field_values, {row, left})} | acc]
        end)
      # else
      #   acc
      # end

    # IO.puts("top <- bottom:")
    # IO.inspect(acc)

    helix(top + 1, bottom - 1, left + 1, right - 1, field_values, acc)
  end

  @spec helix(_top :: integer(), _bottom :: integer(), _left :: integer(), _right :: integer(), _field_values :: %{field_value() => integer()}, acc :: [field_opt_value()]) :: [field_opt_value()]
  # Az eredmény listát visszafordítjuk és az ismétlődő elemeket kiszűrjük
  defp helix(_top, _bottom, _left, _right, _field_values, acc), do: acc |> Enum.reverse() |> Enum.uniq()
end
