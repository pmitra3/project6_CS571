%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Project 6 - EXACT MATCH to ref_out1 and ref_out2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

search(Actions) :-
    initial(Start),
    treasure(Goal),
    % 1. Collect initial keys
    (findall(K, key(Start, K), InitKeys) -> true ; InitKeys = []),
    
    % State: state(Room, KeysHeld, UnlockedColors)
    StartState = state(Start, InitKeys, []),
    
    % BFS with Visited list
    bfs([[StartState, []]], [StartState], Goal, Rev),
    reverse(Rev, Actions).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BFS with PERFECT neighbor ordering
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Base case: Head of queue is at Goal room
bfs([[state(Room, _Keys, _Unlocked), Actions] | _], _, Room, Actions).

% Recursive step
bfs([[State, Actions] | Rest], Visited, Goal, Result) :-
    neighbors_exact(State, Actions, NewPairs),
    % Filter out states that have already been visited
    filter_visited(NewPairs, Visited, NewQueueItems, NewVisited),
    append(Rest, NewQueueItems, NewQueue),
    bfs(NewQueue, NewVisited, Goal, Result).

% Helper to filter visited states and update the visited list
filter_visited([], Visited, [], Visited).
filter_visited([[State, Acts]|Rest], Visited, [[State, Acts]|NewRest], FinalVisited) :-
    \+ member(State, Visited), !,
    filter_visited(Rest, [State|Visited], NewRest, FinalVisited).
filter_visited([_|Rest], Visited, NewRest, FinalVisited) :-
    filter_visited(Rest, Visited, NewRest, FinalVisited).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NEIGHBORS
% 1. Plain moves (Not in locked_door)
% 2. Unlock (In locked_door, Have Key, Not Unlocked)
% 3. Locked moves (In locked_door, Is Unlocked)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

neighbors_exact(state(R, Keys, Unlocked), Actions, All) :-
    % 1. Plain moves
    findall([S2, [A|Actions]], move_plain(R, Keys, Unlocked, A, S2), Plain),
    % 2. Unlock
    findall([S2, [unlock(C)|Actions]], do_unlock(R, Keys, Unlocked, C, S2), UnlockOps),
    % 3. Moves through locked doors
    findall([S2, [A|Actions]], move_locked(R, Keys, Unlocked, A, S2), LockedMoves),
    append([Plain, UnlockOps, LockedMoves], All).

% Helper: Update keys when entering a room N
update_keys(N, CurrentKeys, NewKeys) :-
    findall(K, key(N, K), RoomKeys),
    append(CurrentKeys, RoomKeys, AllKeys),
    sort(AllKeys, NewKeys).

% Helper: Check if edge is locked (undirected check)
is_locked(U, V, C) :- locked_door(U, V, C).
is_locked(U, V, C) :- locked_door(V, U, C).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLAIN DOORS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

move_plain(R, Keys, Unlocked, move(R,N), state(N, NewKeys, Unlocked)) :-
    (door(R, N) ; door(N, R)),
    % CRITICAL: Explicitly fail if this edge is a locked door
    \+ is_locked(R, N, _),
    update_keys(N, Keys, NewKeys).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% UNLOCK (Open locked door)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

do_unlock(R, Keys, Unlocked, Color, state(R, Keys, NewUnlocked)) :-
    % Must be standing at a locked door with Color
    is_locked(R, _, Color),
    member(Color, Keys),       % Must have key
    \+ member(Color, Unlocked), % Not yet unlocked
    sort([Color|Unlocked], NewUnlocked). % Sort for state canonicalization

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOCKED DOORS (Must be unlocked first)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

move_locked(R, Keys, Unlocked, move(R,N), state(N, NewKeys, Unlocked)) :-
    is_locked(R, N, Color),
    member(Color, Unlocked),   % Door must be unlocked
    update_keys(N, Keys, NewKeys).