parent(janos, karoly).
parent(janos, julcsi).
parent(bela, janos).
parent(terez, janos).
parent(geza, bela).

grandparent(A, B) :-
    parent(A, C),
    parent(C, B).

ancestor(A, B) :-
    parent(A, B).
ancestor(A, B) :-
    parent(C, B),
    ancestor(A, C).

sibling(A, B) :-
    parent(P, A),
    parent(P, B),
    A \= B.