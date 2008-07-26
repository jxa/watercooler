-module(sequence).
%%-include_lib("eunit/include/eunit.hrl").
-include_lib("stdlib/include/qlc.hrl").
-compile(export_all).

-record(sequence, {seq, next_id}).

init() ->
    mnesia:create_table(sequence,
                        [{attributes, record_info(fields, sequence)}]).

reset() ->
    mnesia:delete_table(sequence).

create(Table) ->
    Seq = #sequence{seq = Table, next_id = 1},
    base:create(Seq).


%% actually returns the value of the next id
%% most recently used id is current_id -1
current_id(Table) ->
    [{_,_,ID}] = base:find(qlc:q([X || X <- mnesia:table(sequence), X#sequence.seq =:= Table])),
    ID.

next(Table) ->
    F = fun() ->
                %% Get next id in the sequence
                N = current_id(Table),
                %% increment the sequence
                mnesia:write({sequence, Table, N+1}),
                N
        end,
    {atomic, ID} = mnesia:transaction(F),
    ID.

% create tests only if eunit is present and enabled
-ifdef(EUNIT).

-endif.
