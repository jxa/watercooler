-module(users_controller).
-include("/usr/local/lib/yaws/include/yaws_api.hrl").
-export([out/1]).

out(A) ->
    Req = A#arg.req,
    Method = Req#http_request.method,
    Path = string:tokens(A#arg.appmoddata, "/"),
    [Action|_] = Path,
    handle_request(Method, Action, A).

handle_request('POST', "login", A) ->
    {ok, Username} = yaws_api:postvar(A, "username"),
    {ok, Password} = yaws_api:postvar(A, "password"),
    case wc_user:login(Username, Password) of
        bad_user -> [{status, 401}];
        no_password_match -> [{status, 401}];
        ok -> 
            Cookie = yaws_api:new_cookie_session({Username, Password}),
            [{redirect_local, "/rooms"}, yaws_api:setcookie("watercooler-cred", Cookie, "/")]
    end.
