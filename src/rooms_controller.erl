-module(rooms_controller).
-include("/usr/local/lib/yaws/include/yaws_api.hrl").
-export([out/1]).

layout(Content) ->
    {ehtml, [{html, [], 
             {body, [], Content}}]}.

out(A) ->
    case A#arg.appmoddata of
        undefined -> Path = "/";
        _         -> [Path] = string:tokens(A#arg.appmoddata, "/")
    end,
    case api_controller:get_cookie(A) of
        none -> [{status, 401}];
        {OP, _} -> 
            {Username, _} = OP,
            handle_request(Path, Username);
        _ -> [{status, 401}]
    end.

handle_request("/", _Username) ->
    layout([{li, [], room_link(Name)} || Name <- room:all_names()]);

handle_request(Room, Username) ->
    case room:named(Room) of
        [{Name, Topic}] -> 
            [{ssi, "room.ssi", "%", [{"room", Name}, {"topic", Topic}, {"username", Username}] }];
        _ -> [{status, 404}]
    end.

room_link(Room) ->
    Link = "/rooms/" ++ Room,
    {a, [{href, Link}], Room}.
