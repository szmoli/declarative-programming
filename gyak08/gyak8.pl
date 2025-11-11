% 1.

insert_ord([], E, [E]).
insert_ord([H|T], E, RLKi) :-
    E < H,
    RLKi = [E, H|T].

insert_ord([H|T], E, [H|T]) :-
    E = H.

insert_ord([H|T], E, [H|RLKi]) :-
    E > H,
    insert_ord(T, E, RLKi).

% 2.

merge([], RL, RL).
merge([H1|T1], [H2|T2], [H1|Maradek]) :-
    H1 < H2,
    merge(T1, [H2|T2], Maradek).
merge([H1|T1], [H2|T2], [H2|Maradek]) :-
    H1 > H2,
    merge([H1,T1], T2, Maradek).
merge([H1|T1], [H2|T2], [H1|Maradek]) :-
    H1 = H2,
    merge(T1, T2, Maradek).

% 3.

unalmas1(Lista, E) :-
    \+ (append(_, [H|_], Lista),
    H \= E).

unalmas2(Lista, E) :-
    append(L1, _L2, Lista),
    Lista = [E|L1].

% 4.

plato0(L, I, Len, X) :-
    append(L1, L2L3, L),
    append([X,X|_], L3, L2L3),
    append(L2, L3, L2L3), 
    unalmas1(L2, X),
    \+ last(L1, X),
    \+ L3 = [X|_],
    length(L2, Len),
    length(L1, LenL1),
    I is LenL1 + 1.
    
% 5.

pl_kezdetu([X,X|T], 2, T) :-
    T = [H|T1],
    H \= X.

pl_kezdetu([X,X|T], Len, M) :-
    T = [H|T1],
    H = X,
    pl_kezdetu(T1, Len1, M),
    Len is Len1 + 1.