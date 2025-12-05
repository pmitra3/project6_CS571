%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Project 6 - EXACT MATCH to ref_out1 and ref_out2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

search(Actions) :-
    initial(Start),
    treasure(Goal),
    % 1. Collect initial keys
    (findall(K, key(Start, K), InitKeys) -> true ; InitKeys = []),
    
    % 2. Collect ALL locked doors into a list to ensure visibility
    findall(lock(U, V, C), locked_door(U, V, C), Locks),

    % State: state(Room, KeysHeld, UnlockedColors)
    StartState = state(Start, InitKeys, []),
    
    % BFS with Visited list and Locks context
    bfs([[StartState, []]], [StartState], Goal, Locks, Rev),
    reverse(Rev, Actions).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BFS with PERFECT neighbor ordering
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Base case: Head of queue is at Goal room
bfs([[state(Room, _Keys, _Unlocked), Actions] | _], _, Room, _, Actions).

% Recursive step
bfs([[State, Actions] | Rest], Visited, Goal, Locks, Result) :-
    neighbors_exact(State, Actions, Locks, NewPairs),
    % Filter out states that have already been visited
    filter_visited(NewPairs, Visited, NewQueueItems, NewVisited),
    append(Rest, NewQueueItems, NewQueue),
    bfs(NewQueue, NewVisited, Goal, Locks, Result).

% Helper to filter visited states and update the visited list
filter_visited([], Visited, [], Visited).
filter_visited([[State, Acts]|Rest], Visited, [[State, Acts]|NewRest], FinalVisited) :-
    \+ member(State, Visited), !,
    filter_visited(Rest, [State|Visited], NewRest, FinalVisited).
filter_visited([_|Rest], Visited, NewRest, FinalVisited) :-
    filter_visited(Rest, Visited, NewRest, FinalVisited).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NEIGHBORS
% 1. Plain moves (Not in Locks)
% 2. Unlock (In Locks, Have Key, Not Unlocked)
% 3. Locked moves (In Locks, Is Unlocked)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

neighbors_exact(state(R, Keys, Unlocked), Actions, Locks, All) :-
    % 1. Plain moves
    findall([S2, [A|Actions]], move_plain(R, Keys, Unlocked, Locks, A, S2), Plain),
    % 2. Unlock
    findall([S2, [unlock(C)|Actions]], do_unlock(R, Keys, Unlocked, Locks, C, S2), UnlockOps),
    % 3. Moves through locked doors
    findall([S2, [A|Actions]], move_locked(R, Keys, Unlocked, Locks, A, S2), LockedMoves),
    append([Plain, UnlockOps, LockedMoves], All).

% Helper: Update keys when entering a room N
update_keys(N, CurrentKeys, NewKeys) :-
    findall(K, key(N, K), RoomKeys),
    append(CurrentKeys, RoomKeys, AllKeys),
    sort(AllKeys, NewKeys).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLAIN DOORS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

move_plain(R, Keys, Unlocked, Locks, move(R,N), state(N, NewKeys, Unlocked)) :-
    (door(R, N) ; door(N, R)),
    % CRITICAL: Check against the passed Locks list
    % Ensure this door is NOT locked (check both directions)
    \+ member(lock(R, N, _), Locks),
    \+ member(lock(N, R, _), Locks),
    update_keys(N, Keys, NewKeys).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% UNLOCK (Open locked door)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

do_unlock(R, Keys, Unlocked, Locks, Color, state(R, Keys, NewUnlocked)) :-
    % Must be standing at a locked door with Color
    (member(lock(R, _, Color), Locks) ; member(lock(_, R, Color), Locks)),
    member(Color, Keys),       % Must have key
    \+ member(Color, Unlocked), % Not yet unlocked
    sort([Color|Unlocked], NewUnlocked). % Sort for state canonicalization

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOCKED DOORS (Must be unlocked first)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

move_locked(R, Keys, Unlocked, Locks, move(R,N), state(N, NewKeys, Unlocked)) :-
    (member(lock(R, N, Color), Locks) ; member(lock(N, R, Color), Locks)),
    member(Color, Unlocked),   % Door must be unlocked
    update_keys(N, Keys, NewKeys).