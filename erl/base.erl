-module(base).
%%-include_lib("eunit/include/eunit.hrl").
-include_lib("stdlib/include/qlc.hrl").
%% -include("message.erl").
%% -include("room.erl").
%% -include("sequence.erl").
-compile(export_all).

init() ->
    mnesia:start(),
    sequence:init(),
    message:init(),
    room:init(),
    load().

load() ->
    message:load(),
    room:load(),
    ok.

reset() ->
    message:reset(),
    room:reset(),
    sequence:reset().

create(Row) ->
    Fun = fun()->
                  mnesia:write(Row)
          end,
    mnesia:transaction(Fun).

find(Q) ->
    F = fun() ->
                 qlc:e(qlc:sort(Q)) end,
    {atomic, Val} = mnesia:transaction(F),
    Val.

find_all(Table) ->
    find(qlc:q([R || R <- mnesia:table(Table)])).

% create tests only if eunit is present and enabled
-ifdef(EUNIT).

-endif.
