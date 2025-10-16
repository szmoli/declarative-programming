defmodule Nhf1 do
  @moduledoc """
  Számtekercs
  @author "Szmoleniczki Ákos <szmoleniczki.akos@edu.bme.hu>"
  @date   "2025-10-24"
  ...
  """
  # tábla mérete (0 < n)
  @type size() :: integer()
  # ciklus hossza (0 < m <= n)
  @type cycle() :: integer()
  # mező értéke (0 < v <= m)
  @type value() :: integer()

  # sor száma (1-től n-ig)
  @type row() :: integer()
  # oszlop száma (1-től n-ig)
  @type col() :: integer()
  # mező koordinátái
  @type field() :: {row(), col()}

  # mező és értéke
  @type field_value() :: {field(), value()}
  # feladvány
  @type puzzle_desc() :: {size(), cycle(), [field_value()]}

  # eredménymező értéke (0 <= rv <= m)
  @type retval() :: integer()
  # egy megoldás
  @type solution() :: [[retval()]]
  # összes megoldás
  @type solutions() :: [solution()]

  @spec helix(sd :: puzzle_desc()) :: ss :: solutions()
  # ss az sd feladványleíróval megadott feladvány összes megoldásának listája
  def helix(sd) do
    ...
  end
end
