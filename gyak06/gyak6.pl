komplementer(0, 1).
komplementer(1, 0).

forditottja([], []).
forditottja([H1|T1], [H2|T2]) :-
	komplementer(H1, H2),
    forditottja(T1, T2).

% ---

noveltje([], []).
noveltje([H1|T1], [H2|T2]) :-
	H2 is H1 + 1,
	noveltje(T1, T2).
    
% ---

utolso([H], H).
utolso([H|T], E) :-
	utolso(T, E).
    
% ---

szekvencia(Kezdet, Veg, []) :-
	Veg is Kezdet - 1.
szekvencia(Kezdet, Veg, [Kezdet|Maradek]) :-
	Veg > Kezdet - 1,
    UjKezdet is Kezdet + 1,
    szekvencia(UjKezdet, Veg, Maradek).
    
% ---

max(N, X) :-
    integer(N),
    N > 0,
    between(1, N, X).
    
% ---

