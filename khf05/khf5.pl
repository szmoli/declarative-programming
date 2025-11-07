:- use_module(library(lists)).

% :- type feladvany_leiro ---> szt(meret, ciklus, list(adott_elem)).
% :- type meret             == integer.
% :- type ciklus            == integer.
% :- type adott_elem      ---> i(sorszam, oszlopszam, ertek).
% :- type sorszam           == integer.
% :- type oszlopszam        == integer.
% :- type ertek             == integer.

% :- type t_matrix          == list(t_sor).
% :- type t_sor             == list(t_ertek).
% :- type t_ertek           == list(integer) \/ integer.  % egészek listája vagy egész

% :- pred szamok(integer::in, integer::in, t_ertek::out).
szamok(Tol, Tol, [Tol]) :- !. 

szamok(Tol, Ig, [Tol|Maradek]) :-
    Tol < Ig,
    Tol1 is Tol + 1,
    szamok(Tol1, Ig, Maradek).

szamok(Tol, Ig, [Tol|Maradek]) :-
    Tol > Ig,
    Tol1 is Tol - 1,
    szamok(Tol1, Ig, Maradek).

% :- pred ertek(sorszam::in, oszlopszam::in, feladvany_leiro::in, t_ertek::out).
t_ertek(Sorszam, Oszlopszam, szt(_N, _M, Adottak), [Adott]) :-
    member(i(Sorszam, Oszlopszam, Adott), Adottak), !.

t_ertek(Sorszam, Oszlopszam, szt(N, M, Adottak), TErtek) :-
    N > M,
    szamok(0, M, TErtek).

t_ertek(Sorszam, Oszlopszam, szt(N, M, Adottak), TErtek) :-
    N =:= M,
    szamok(1, M, TErtek).

t_sor(Sorszam, szt(N, M, Adottak), TSor) :- 
    szamok(1, N, Oszlopszamok),
    t_sor(Sorszam, Oszlopszamok, szt(N, M, Adottak), TSor).

t_sor(Sorszam, [Oszlopszam], szt(N, M, Adottak), [TErtek]) :-
    t_ertek(Sorszam, Oszlopszam, szt(N, M, Adottak), TErtek).

t_sor(Sorszam, [Oszlopszam|Oszlopszamok], szt(N, M, Adottak), [TErtek|Maradek]) :-
    t_ertek(Sorszam, Oszlopszam, szt(N, M, Adottak), TErtek),
    t_sor(Sorszam, Oszlopszamok, szt(N, M, Adottak), Maradek).


% :- pred kezdotabla(feladvany_leiro::in, t_matrix::out).
kezdotabla(szt(N, M, Adottak), Mx) :-
    t_matrix(szt(N, M, Adottak), Mx).

t_matrix(szt(N, M, Adottak), Mx) :-
    szamok(1, N, Szamok),
    t_matrix(Szamok, szt(N, M, Adottak), Mx).

t_matrix([Sorszam], szt(N, M, Adottak), [TSor]) :-
    t_sor(Sorszam, szt(N, M, Adottak), TSor).

t_matrix([Sorszam|Sorszamok], szt(N, M, Adottak), [TSor|Maradek]) :-
    t_sor(Sorszam, szt(N, M, Adottak), TSor),
    t_matrix(Sorszamok, szt(N, M, Adottak), Maradek).

% :- pred ismert_szukites(feladvany_leiro::in, t_matrix::in, t_matrix::out).