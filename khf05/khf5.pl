:- use_module(library(lists)).
:- use_module(library(clpfd)).

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

% :- pred t_ertek(sorszam::in, oszlopszam::in, feladvany_leiro::in, t_ertek::out).
t_ertek(Sorszam, Oszlopszam, szt(_N, _M, Adottak), [Adott]) :-
    member(i(Sorszam, Oszlopszam, Adott), Adottak), !.

t_ertek(_Sorszam, _Oszlopszam, szt(N, M, _Adottak), TErtek) :-
    N > M,
    szamok(0, M, TErtek).

t_ertek(_Sorszam, _Oszlopszam, szt(N, M, _Adottak), TErtek) :-
    N =:= M,
    szamok(1, M, TErtek).

% pred t_sor(sorszam::in, feladvany_leiro::in, t_sor::out).
t_sor(Sorszam, szt(N, M, Adottak), TSor) :- 
    szamok(1, N, Oszlopszamok),
    t_sor(Sorszam, Oszlopszamok, szt(N, M, Adottak), TSor).

t_sor(Sorszam, [Oszlopszam], szt(N, M, Adottak), [TErtek]) :-
    t_ertek(Sorszam, Oszlopszam, szt(N, M, Adottak), TErtek).

t_sor(Sorszam, [Oszlopszam|Oszlopszamok], szt(N, M, Adottak), [TErtek|Maradek]) :-
    t_ertek(Sorszam, Oszlopszam, szt(N, M, Adottak), TErtek),
    t_sor(Sorszam, Oszlopszamok, szt(N, M, Adottak), Maradek).

% pred t_matrix(feladvany_leiro::in, t_matrix::out).
t_matrix(szt(N, M, Adottak), Mx) :-
    szamok(1, N, Szamok),
    t_matrix(Szamok, szt(N, M, Adottak), Mx).

t_matrix([Sorszam], szt(N, M, Adottak), [TSor]) :-
    t_sor(Sorszam, szt(N, M, Adottak), TSor).

t_matrix([Sorszam|Sorszamok], szt(N, M, Adottak), [TSor|Maradek]) :-
    t_sor(Sorszam, szt(N, M, Adottak), TSor),
    t_matrix(Sorszamok, szt(N, M, Adottak), Maradek).

% :- pred kezdotabla(feladvany_leiro::in, t_matrix::out).
kezdotabla(szt(N, M, Adottak), Mx) :-
    t_matrix(szt(N, M, Adottak), Mx).

% pred sor(sorszam::in, t_matrix::in, t_sor::out).
sor(Sorszam, Mx, TSor) :-
    nth1(Sorszam, Mx, TSor).

% pred oszlop(oszlopszam::in, t_matrix::in, t_sor::out).
oszlop(Oszlopszam, Mx, TOszlop) :-
    maplist(nth1(Oszlopszam), Mx, TOszlop).

% pred adott(t_sor::in, ertek::out).
adott([E], E).

t_sor_szukites(E, TSor, SzTSor) :-
    maplist(t_ertek_szukites(E), TSor, SzTSor).

% t_ertek_szukites(_, E, E) :- 
%     integer(E), !.
% 
% t_ertek_szukites(_, [E], E) :- !.
% 
% t_ertek_szukites(E, TErtek, SzTErtek) :-
%     select(E, TErtek, SzTErtek).
% 
% t_matrix_szukites(E, Mx, SzMx) :-
%     maplist(t_sor_szukites(E), Mx, SzMx).

elhagy(_, E, E) :-
    integer(E), !.

elhagy(E, [E], E) :-
    integer(E), !.

elhagy(E, TErtek, SzTErtek) :-
    select(E, TErtek, SzTErtek).

ertek(Sorszam, Oszlopszam, Mx, E) :-
    nth1(Sorszam, Mx, Sor),
    nth1(Oszlopszam, Sor, E).

% szukites(E, TSorBe, TSorKi) :-
%     E = 0.
% 
% szukites(E, TSor, SzTSor) :-
%     E > 0,
%     maplist(elhagy(E), TSor, SzTSor).
% 
% szukites_rossz([]).

sorbol_elhagy(_, _, [], []).
sorbol_elhagy(E, 1, [H|T1], [H|T2]) :-  
    sorbol_elhagy(E, 0, T1, T2), !.
sorbol_elhagy(E, N, [H1|T1], [H2|T2]) :-
    select(E, H1, H2), !,
    N1 is N - 1,
    sorbol_elhagy(E, N1, T1, T2).
sorbol_elhagy(E, N, [H|T1], [H|T2]) :-
    N1 is N - 1,
    sorbol_elhagy(E, N1, T1, T2).

oszlopbol_elhagy(E, N, TOszlopBe, TOszlopKi) :-
    sorbol_elhagy(E, N, TOszlopBe, TOszlopKi).

szukitett_sor(Sorszam, MxIn, SzTSor, MxOut) :-
    nth1(Sorszam, MxIn, _, Maradek),
    nth1(Sorszam, MxOut, SzTSor, Maradek).

szukitett_oszlop(Oszlopszam, MxIn, SzTOszlop, MxOut) :-
    transpose(MxIn, MxInT),
    nth1(Oszlopszam, MxInT, _, Maradek),
    nth1(Oszlopszam, MxOutT, SzTOszlop, Maradek),
    transpose(MxOutT, MxOut).

% ismert_szukites(szt(N, M, _), MxIn, )

% :- pred ismert_szukites(feladvany_leiro::in, t_matrix::in, t_matrix::out).
% ismert_szukites(szt(N, M, _), MxIn, _MxOut) :-
%     ertek(Sorszam, Oszlopszam, MxIn, TErtek),
%     adott(TErtek, Ertek),
%     sor(Sorszam, MxIn, TSor),
%     szukites(Ertek, TSor, SzTSor),
%     oszlop(Oszlopszam, MxIn, TOszlop),
%     szukites(Ertek, TOszlop, SzTOszlop).