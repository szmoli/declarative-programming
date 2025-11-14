:- use_module(library(lists)).

% :- type feladvany_leiro ---> szt(meret,ciklus,list(adott_elem)).
% :- type meret             == integer.
% :- type ciklus            == integer.
% :- type adott_elem      ---> i(sorszam,oszlopszam,ertek).
% :- type sorszam           == integer.
% :- type oszlopszam        == integer.
% :- type ertek             == integer.

% :- type t_matrix          == list(t_sor).
% :- type t_sor             == list(t_ertek).
% :- type t_ertek           == list(integer) \/ integer.  % egészek listája vagy egész

% :- type szukites        ---> sor(sorszam,ertek) ; oszl(oszlopszam,ertek) ; nem.

% :- pred kizarasos_szukites(feladvany_leiro::in, t_matrix::in, t_matrix::out, szukites::out).

% Tartomány felveheti-e E-t.
felveheti(E, E) :-
    integer(E).
felveheti(Tartomany, E) :-
    is_list(Tartomany),
    member(E, Tartomany).

% Egy vonal elemei, amik felvehetik E-t.
felvehetik([], _, []).
felvehetik([H|T1], E, [H|T2]) :-
    felveheti(H, E),
    !,
    felvehetik(T1, E, T2).
felvehetik([_|T], E, Felvehetik) :-
    felvehetik(T, E, Felvehetik).

% Egy lista hány eleme lista.
lista_darab([], 0).
lista_darab([H|T], Darab) :-
    lista_darab(T, Darab1),
    (   
        is_list(H) -> Darab is Darab1 + 1
    ;   
        Darab = Darab1
    ).

% Mátrix sora.
sor(Ix, Mx, Sor) :-
    nth1(Ix, Mx, Sor).

% Mátrix oszlopa.
oszlop(Ix, Mx, Oszlop) :-
    maplist(nth1(Ix), Mx, Oszlop).

% Megfelel-e a feladatban adott feltételeknek a vonal.
vonal_helyes(Vonal, E, Z) :-
    felvehetik(Vonal, E, Fel),
    length(Fel, Cnt),
    Cnt > 0,
    lista_darab(Fel, ListDB),
    ListDB > 0,
    (   
        E = 0 -> Cnt =< Z
    ;   
        E > 0 -> Cnt =< 1
    ).

sor_keres(N, Mx, E, Z, SorIx, Vonal) :-
    between(1, N, SorIx),
    sor(SorIx, Mx, Vonal),
    vonal_helyes(Vonal, E, Z),
    !.

oszlop_keres(N, Mx, E, Z, OszlopIx, Vonal) :-
    between(1, N, OszlopIx),
    oszlop(OszlopIx, Mx, Vonal),
    vonal_helyes(Vonal, E, Z),
    !.

% Első jó vonal.
vonal_keres(N, M, Mx, SorIx, OszlopIx, Tipus, Vonal) :-
    Z is N - M,
    between(0, M, E),
        (   sor_keres(N, Mx, E, Z, SorIx, Vonal)
        ->  Tipus = sor,
            OszlopIx = 0
        ;   oszlop_keres(N, Mx, E, Z, OszlopIx, Vonal)
        ->  Tipus = oszlop,
            SorIx = 0
        ),
    !.
    

% Veszünk egy E értéket 0..M közül növekvő sorrendbe
% Keressük az első sort vagy oszlopot, ami:
