%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Project 6 - EXACT MATCH to ref_out1 and ref_out2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

search(Actions) :-
    initial(Start),
    treasure(Goal),
    bfs([[state(Start, []), []]], Goal, Rev),
    reverse(Rev, Actions).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BFS with PERFECT neighbor ordering
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

bfs([[state(Room, Keys), Actions] | _], Room, Actions).

bfs([[State, Actions] | Rest], Goal, Result) :-
    neighbors_exact(State, Actions, NewPairs),
    append(Rest, NewPairs, NewQueue),
    bfs(NewQueue, Goal, Result).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXACT ORDER:
% 1. move through UNLOCKED doors
% 2. UNLOCK (pick up key)
% 3. move through LOCKED doors (if key held)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

neighbors_exact(state(R, Keys), Actions, All) :-
    % 1. Plain moves
    findall([S2, [A|Actions]], move_plain(R, Keys, A, S2), Plain),
    % 2. Unlock
    findall([S2, [unlock(C)|Actions]], do_unlock(R, Keys, C, S2), Unlock),
    % 3. Moves through locked doors
    findall([S2, [A|Actions]], move_locked(R, Keys, A, S2), Locked),
    append([Plain, Unlock, Locked], All).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLAIN DOORS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

move_plain(R, Keys, move(R,N), state(N,Keys)) :- door(R,N).
move_plain(R, Keys, move(R,N), state(N,Keys)) :- door(N,R).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% UNLOCK (pick up key at same room)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

do_unlock(R, Keys, Color, state(R, NewKeys)) :-
    key(R, Color),
    \+ member(Color, Keys),
    NewKeys = [Color|Keys].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOCKED DOORS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

move_locked(R, Keys, move(R,N), state(N,Keys)) :-
    locked_door(R,N,Color),
    member(Color, Keys).

move_locked(R, Keys, move(R,N), state(N,Keys)) :-
    locked_door(N,R,Color),
    member(Color, Keys).
