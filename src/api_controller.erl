-module(api_controller).
-include("/usr/local/lib/yaws/include/yaws_api.hrl").
-export([out/1, get_cookie/1, current_user/1]).

out(A) ->
%%    io:format("~p~n", [A]),
    Req = A#arg.req,
    Method = Req#http_request.method,
    Path = string:tokens(A#arg.appmoddata, "/"),
    io:format("Cookie: ~p~n",[get_cookie(A)]),
    case Path of
        ["rooms"|_] -> rooms_controller:out(A);
        ["messages"|Tail] -> messages_controller:handle_request(Method, Tail, A);
        _ -> [{status, 404}]
    end.

get_cookie(A) ->
    H = A#arg.headers,
    C = H#headers.cookie,
    case yaws_api:find_cookie_val("watercooler-cred", C) of
        [] -> none;
        Cookie ->
            case yaws_api:cookieval_to_opaque(Cookie) of
                {ok, OP} -> {OP, Cookie};
                _ -> none
            end
    end.

current_user(A) ->
    case get_cookie(A) of
        none -> none;
        {{Username, Password}, _} ->
            case wc_user:login(Username, Password) of
                ok -> Username;
                _  -> none
            end;
        _ -> none
     end.
