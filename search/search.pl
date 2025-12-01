%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Correct search for Project 6 – EXACT BFS ORDER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

search(Actions) :-
    initial(Start),
    treasure(Goal),
    bfs([[state(Start, []), []]], Goal, Rev),
    reverse(Rev, Actions).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BFS – maintains exact neighbor ordering
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

bfs([[state(Room, Keys), Actions] | _], Room, Actions).

bfs([[State, Actions] | Rest], Goal, Result) :-
    neighbors_in_order(State, Actions, NewStates),
    append(Rest, NewStates, NewQueue),
    bfs(NewQueue, Goal, Result).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% neighbors_in_order(State, Actions, NextStates)
% EXPLORE IN THIS EXACT ORDER:
%   1. unlock actions
%   2. move through plain doors
%   3. move through locked doors (only if key held)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

neighbors_in_order(State, Actions, All) :-
    findall([NextState, [Act|Actions]], unlock_action(State,Act,NextState), Unlocks),
    findall([NextState, [Act|Actions]], move_plain(State,Act,NextState), PlainMoves),
    findall([NextState, [Act|Actions]], move_locked(State,Act,NextState), LockedMoves),
    append([Unlocks, PlainMoves, LockedMoves], All).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% UNLOCK ACTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

unlock_action(state(R, Keys), unlock(Color), state(R, [Color|Keys])) :-
    key(R, Color),
    \+ member(Color, Keys).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MOVE THROUGH UNLOCKED DOORS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

move_plain(state(R, Keys), move(R,N), state(N, Keys)) :-
    door(R, N).

move_plain(state(R, Keys), move(R,N), state(N, Keys)) :-
    door(N, R).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MOVE THROUGH LOCKED DOORS (ONLY IF WE HAVE KEY)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

move_locked(state(R, Keys), move(R,N), state(N, Keys)) :-
    locked_door(R, N, Color),
    member(Color, Keys).

move_locked(state(R, Keys), move(R,N), state(N, Keys)) :-
    locked_door(N, R, Color),
    member(Color, Keys).
