% P1

komplementer(0, 1).
komplementer(1, 0).

forditottja([], []).
forditottja([H1|T1], [H2|T2]) :-
	komplementer(H1, H2),
    forditottja(T1, T2).

% P2

noveltje([], []).
noveltje([H1|T1], [H2|T2]) :-
	H2 is H1 + 1,
	noveltje(T1, T2).
    
% P3

utolso([H], H).
utolso([_H|T], E) :-
	utolso(T, E).
    
% P4

szekvencia(Kezdet, Veg, []) :-
	Veg is Kezdet - 1.
szekvencia(Kezdet, Veg, [Kezdet|Maradek]) :-
	Veg > Kezdet - 1,
    UjKezdet is Kezdet + 1,
    szekvencia(UjKezdet, Veg, Maradek).
    
% P5

max(N, N).
max(N, X) :-
    N > 1,
    N1 is N - 1,
    max(N1, X).
    
% P6

ennedik(1, [H|_T], H).
ennedik(N, [H|T], E) :-
    integer(N),
    N >= 1,
    length([H|T], Len),
    N =< Len,
    N1 is N - 1,
    ennedik(N1, T, E).


% P7

prefixum(_, 0, []).
prefixum([H|T], Hossz, [H|P]) :-
    integer(Hossz),
    Hossz >= 0,
    length([H|T], Len),
    Hossz =< Len,
    Hossz1 is Hossz - 1,
    prefixum(T, Hossz1, P).

% P8

szuffixum(L, 0, L).
szuffixum([_H|T], Hossz, S) :-
    Hossz1 is Hossz - 1,
    szuffixum(T, Hossz1, S).

% P9

ennedik_csere(1, [E0|L0], E0, [E|L0], E).
ennedik_csere(N, [X|L0], E0, [X|L], E) :-
    N > 1, N1 is N-1, ennedik_csere(N1, L0, E0, L, E).

% P10

prefixumok(_, []).
prefixumok([H|T], [H|P]) :-
    prefixumok(T, P).

% P11

reszlista(L, R, Elotte, Hossz) :-
    szuffixum(L, Elotte, S),
    prefixum(S, Hossz, R).

% P12

ennedik_f(1, [H|_], H).
ennedik_f(N, [_|T], E) :-
    ennedik_f(N1, T, E),
    N is N1+1.