-module(rooms_controller).
-include("/usr/local/lib/yaws/include/yaws_api.hrl").
-export([out/1]).

layout(Content) ->
    {ehtml, [{html, [], 
             {body, [], Content}}]}.

out(A) ->
    Path = string:tokens(A#arg.appmoddata, "/"),
    [Room] = Path,
    case room:named(Room) of
        [{Name, Topic}] -> 
            [{ssi, "room.ssi", "%", [{"room", Name}, {"topic", Topic}] }];
        _ -> [{status, 404}]
    end.

rooms_list() ->
    [{li, [], Name} || Name <- room:all_names()].
