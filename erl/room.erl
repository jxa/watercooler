-module(room).
%%-include_lib("eunit/include/eunit.hrl").
-include_lib("stdlib/include/qlc.hrl").
-compile(export_all).

-record(room, {name, created_on, subject}).

init() ->
    mnesia:create_table(room,
                        [{attributes, record_info(fields, room)}]).

load() ->
    Rooms = [{"braintree", "watercooler chat"},
             {"developers", "13375p33k 0n1y"}],
    [create(N,S) || {N,S} <- Rooms].

reset() ->
    mnesia:delete_table(room).

create(Name, Subject) ->
    Room = #room{name = Name, subject = Subject},
    base:create(Room).

all() ->
    base:find_all(room).

all_names() ->
    [R#room.name || R <- all()].

% create tests only if eunit is present and enabled
-ifdef(EUNIT).

-endif.
