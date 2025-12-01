%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Project 6 Search – NO UNLOCK ACTIONS IN OUTPUT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

search(Actions) :-
    initial(Start),
    treasure(Goal),
    bfs([[state(Start, []), []]], Goal, RevActions),
    reverse(RevActions, Actions).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BFS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

bfs([[state(Room, Keys), Actions] | _], Room, Actions).

bfs([[State, Actions] | Rest], Goal, Result) :-
    neighbors(State, Actions, NewStates),
    append(Rest, NewStates, NewQueue),
    bfs(NewQueue, Goal, Result).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate neighbors IN EXACT ORDER:
% 1. Pick up key (silent – NOT added to Actions)
% 2. Moves through plain doors
% 3. Moves through locked doors IF key held
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

neighbors(State, Actions, All) :-
    findall([S2, Actions], silent_unlock(State, S2), Unlocks),
    findall([S2, [Act|Actions]], move_plain(State, Act, S2), PlainMoves),
    findall([S2, [Act|Actions]], move_locked(State, Act, S2), LockedMoves),
    append([Unlocks, PlainMoves, LockedMoves], All).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INTERNAL KEY PICKUP (NO ACTION ADDED TO OUTPUT)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

silent_unlock(state(R, Keys), state(R, [Color|Keys])) :-
    key(R, Color),
    \+ member(Color, Keys).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MOVE THROUGH PLAIN DOORS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

move_plain(state(R, Keys), move(R, N), state(N, Keys)) :-
    door(R, N).

move_plain(state(R, Keys), move(R, N), state(N, Keys)) :-
    door(N, R).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MOVE THROUGH LOCKED DOORS (IF KEY HELD)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

move_locked(state(R, Keys), move(R, N), state(N, Keys)) :-
    locked_door(R, N, Color),
    member(Color, Keys).

move_locked(state(R, Keys), move(R, N), state(N, Keys)) :-
    locked_door(N, R, Color),
    member(Color, Keys).
