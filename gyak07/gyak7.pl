% 1.

fa_pontszama(leaf(_), 0).
fa_pontszama(node(L, R), N) :-
    fa_pontszama(L, N1),
    fa_pontszama(R, N2),
    N is N1 + N2 + 1.

% 2.

fa_noveltje(leaf(X), leaf(Y)) :-
    Y is X + 1.
fa_noveltje(node(L, R), node(L2, R2)) :-
    fa_noveltje(L, L2),
    fa_noveltje(R, R2).

% 3.

fa_levelerteke(leaf(V), V).
fa_levelerteke(node(L, _), V) :-
    fa_levelerteke(L, V).
fa_levelerteke(node(_, R), V) :-
    fa_levelerteke(R, V).

% 4.

fa_reszfaja(node(L, R), node(L, R)).
fa_reszfaja(node(leaf(L), _), leaf(L)).
fa_reszfaja(node(_, leaf(R)), leaf(R)).
fa_reszfaja(node(L, _), Resz) :-
    fa_reszfaja(L, Resz).
fa_reszfaja(node(_, R), Resz) :-
    fa_reszfaja(R, Resz).

% 5.

reszsorozata(L, L).
reszsorozata(R, [_|T]) :-
    reszsorozata(R, T).

% 6.

app([], B, B).
app([X|A], B, [X|C]) :-
    app(A, B, C).

member_a(L, M) :-
    app(_, [M|_], L).

member_b([H|_], H).
member_b([_|T], M) :-
    member_b(T, M).

% 7.

select_a(E, L, R) :-
    app(F, [E|T], L),
    app(F, T, R).

% 8.

nth0_a(Nth, L, E) :-
    app(F, [E|_], L),
    length(F, Len), 
    Len = Nth.

% 9.

alapkif(K) :- 
    integer(K), K > 0.
alapkif(K1+K2) :- 
    alapkif(K1),
    alapkif(K2).
alapkif(K1-K2) :- 
    alapkif(K1),
    alapkif(K2).
alapkif(K1/K2) :- 
    alapkif(K1),
    alapkif(K2).
alapkif(K1*K2) :- 
    alapkif(K1),
    alapkif(K2).

% 10.

cd_kif(K) :- 
    integer(K), K > 0.
cd_kif(K1+K2) :- 
    cd_kif(K1),
    cd_kif(K2),
    K is K1+K2,
    integer(K), K > 0.
cd_kif(K1-K2) :- 
    cd_kif(K1),
    cd_kif(K2),
    K is K1-K2,
    integer(K), K > 0.
cd_kif(K1/K2) :- 
    cd_kif(K1),
    cd_kif(K2),
    K is K1/K2,
    integer(K), K > 0.
cd_kif(K1*K2) :- 
    cd_kif(K1),
    cd_kif(K2),
    K is K1*K2,
    integer(K), K > 0.
