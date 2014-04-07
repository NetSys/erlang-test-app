-module(test_app).

%% Application callbacks
-export([test_fun/0, send_fun/3, rec_fun/1]).


rec_fun(Count) ->
    receive
        {quit, Sender} -> 
            Sender ! ok,
            ok;
        {_, Sender} -> Sender ! {ok, Count}, 
            rec_fun(Count + 1)
    end.

send_fun(Pid, Parent, Loop) ->
    Pid ! {foo, self()}, 
    receive
      {ok, Count} -> 
        io:format("~p received ~p~n", [self(), Count]),
        case Loop of
          0 -> Parent ! ok;
          _ -> send_fun(Pid, Parent, Loop - 1)
        end
    end.

wait(Count) ->
    receive 
        ok ->
         case (Count - 1) of
           0 -> ok;
           _ -> wait(Count - 1)
         end
    end.

test_fun () ->
    Rec0 = spawn(fun() -> rec_fun(0) end),
    Rec1 = spawn(fun() -> rec_fun(1) end),
    Self = self(),
    spawn(fun() -> send_fun(Rec0, Self, 3) end),
    spawn(fun() -> send_fun(Rec0, Self, 2) end),
    spawn(fun() -> send_fun(Rec1, Self, 3) end),
    wait(3),
    Rec0 ! {quit, self()},
    Rec1 ! {quit, self()},
    wait(2),
    io:format("------------------------------------------~n").
