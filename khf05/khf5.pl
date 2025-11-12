% Szmoleniczki Ákos (szmoleniczki.akos@edu.bme.hu)
% 2025-11-10
%  Minimális segítségkérések a ChatGPT-től a feladat megoldása során:
% - Elmagyarázta a Prolog \+ (negáció) operátor működését és alternatíváit.
% - Segített megtalálni, miért generált több megoldást az ismert_szukites/3, mint amennyi várt volt.
% - Rámutatott, hogy a rekurzió miatt a predikátum többször visszatérhetett ugyanazzal az eredménnyel.
% - Segített megoldani, hogy az ismert_szukites/3 bukjon el, ha nincsenek ismert értékek a mátrixban.
% - Segített pontosítani a vágások (!) helyes használatát.

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
szamok(Tol, Ig, []) :-
    Tol > Ig, !.
szamok(Tol, Ig, [Tol|Maradek]) :-
    Kovetkezo is Tol + 1,
    szamok(Kovetkezo, Ig, Maradek).

% :- pred t_ertek(sorszam::in, oszlopszam::in, feladvany_leiro::in, t_ertek::out).
t_ertek(Sorszam, Oszlopszam, szt(_N, _M, Adottak), [Adott]) :-
    member(i(Sorszam, Oszlopszam, Adott), Adottak), !.

t_ertek(_, _, szt(N, M, _), TErtek) :-
    N > M, !,
    szamok(0, M, TErtek).

t_ertek(_, _, szt(_N, M, _), TErtek) :-
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

darab(_, [], 0) :- !.
darab(E, [E|T], Db) :-
    darab(E, T, Db1),
    Db is Db1 + 1, !.
darab(E, [H|T], Db) :-
    E \= H,
    darab(E, T, Db), !.

van_egyelemu(Mx, SorIndex, OszlopIndex, Sor, Oszlop, E) :-
    nth1(SorIndex, Mx, Sor),
    nth1(OszlopIndex, Sor, [E]),
    maplist(nth1(OszlopIndex), Mx, Oszlop),
    !.

osszes_csere(_E, _UjE, [], []).
osszes_csere(E, UjE, [E|T], [UjE|M]) :-
    osszes_csere(E, UjE, T, M), !.
osszes_csere(E, UjE, [H|T], [H|R]) :-
    H \= E,
    osszes_csere(E, UjE, T, R), !.

elhagy(_, E, E) :- number(E), !.
elhagy(_, [], []) :- !.
elhagy(E, [E], []) :- !.
elhagy(E, [E|T], M) :-
    elhagy(E, T, M), !.
elhagy(E, [H|T], [H|M]) :-
    E \= H,
    elhagy(E, T, M), !.

elhagy_kiveve(_, _, [], []) :- !.
elhagy_kiveve(E, 1, [H1|T1], [H1|T2]) :- 
    elhagy_kiveve(E, 0, T1, T2), !.
elhagy_kiveve(E, Ix, [H1|T1], [H2|T2]) :-
    Ix1 is Ix - 1,
    elhagy(E, H1, H2),
    elhagy_kiveve(E, Ix1, T1, T2).

cserel_sor(Matrix, 1, Sor, [Sor|T]) :-  % ha az első sort cseréljük
    Matrix = [_|T].
cserel_sor([H|T], Index, Sor, [H|R]) :-
    Index > 1,
    NewIndex is Index - 1,
    cserel_sor(T, NewIndex, Sor, R).

cserel_oszlop([], _, [], []).  % ha nincs több sor, kész
cserel_oszlop([Sor|T], Index, [Elem|VegsoOszlopT], [UjSor|UjMatrixT]) :-
    cserel_lista_elem(Sor, Index, Elem, UjSor),
    cserel_oszlop(T, Index, VegsoOszlopT, UjMatrixT).

cserel_lista_elem([_|T], 1, Elem, [Elem|T]).
cserel_lista_elem([H|T], Index, Elem, [H|R]) :-
    Index > 1,
    NewIndex is Index - 1,
    cserel_lista_elem(T, NewIndex, Elem, R).

szukites(0, ElvartZ, SorIx, OszlopIx, Sor, Oszlop, MxBe, MxKi) :-
    szukites_nullas(ElvartZ, SorIx, OszlopIx, Sor, Oszlop, MxBe, MxKi),
    !.
szukites(E, _ElvartZ, SorIx, OszlopIx, Sor, Oszlop, MxBe, MxKi) :-
    E > 0,
    szukites_pozitiv(E, SorIx, OszlopIx, Sor, Oszlop, MxBe, MxKi), 
    !.   

szukites_pozitiv(E, SorIx, OszlopIx, Sor, Oszlop, MxBe, MxKi) :-
    elhagy_kiveve(E, OszlopIx, Sor, ElhagyottSor),
    ( 
        member([], ElhagyottSor) -> MxKi = [] 
    ;
        elhagy_kiveve(E, SorIx, Oszlop, ElhagyottOszlop),
        ( 
            member([], ElhagyottOszlop) -> MxKi = [] 
        ;
            cserel_lista_elem(ElhagyottOszlop, SorIx, E, CsereltOszlop),
            cserel_sor(MxBe, SorIx, ElhagyottSor, MxSorCserelt),
            cserel_oszlop(MxSorCserelt, OszlopIx, CsereltOszlop, MxKi)
        )
    ).

szukites_nullas(ElvartZ, SorIx, OszlopIx, Sor, Oszlop, MxBe, MxKi) :-
    osszes_csere([0], 0, Sor, CsereltSor),
    darab(0, CsereltSor, SorZ),
    ( 
        SorZ > ElvartZ -> MxKi = [] 
    ;
        SorZ =:= ElvartZ -> 
        maplist(elhagy(0), CsereltSor, VegsoSor),

        osszes_csere([0], 0, Oszlop, CsereltOszlop),
        darab(0, CsereltOszlop, OszlopZ),
        ( 
            OszlopZ > ElvartZ -> MxKi = [] 
        ;
            OszlopZ =:= ElvartZ -> 
            maplist(elhagy(0), CsereltOszlop, VegsoOszlop),
            cserel_sor(MxBe, SorIx, VegsoSor, MxSorCserelt),
            cserel_oszlop(MxSorCserelt, OszlopIx, VegsoOszlop, MxKi)
        )
    ).

ismert_szukites(_, [], []) :- !.

ismert_szukites(szt(N,M,_), MxBe, MxKi) :-
    van_egyelemu(MxBe, SorIx, OszlopIx, Sor, Oszlop, E), 
    ElvartZ is N - M,
    szukites(E, ElvartZ, SorIx, OszlopIx, Sor, Oszlop, MxBe, MxSzukitett),
    ismert_szukites(szt(N,M,_), MxSzukitett, MxKi).

ismert_szukites(_, Mx, Mx).  
