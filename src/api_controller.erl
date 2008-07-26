-module(api_controller).
-include("/usr/local/lib/yaws/include/yaws_api.hrl").
-export([out/1]).

out(A) ->
%%    io:format("~p~n", [A]),
    Req = A#arg.req,
    Method = Req#http_request.method,
    Path = string:tokens(A#arg.appmoddata, "/"),
%%    io:format("~p - ~p~n",[Method, Req#http_request.path]),
    case Path of
        ["rooms"|_] -> rooms_controller:out(A);
        ["messages"|Tail] -> messages_controller:handle_request(Method, Tail, A);
        _ -> [{status, 404}]
    end.
