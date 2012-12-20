-module(ev8call_srv).

-behaviour(gen_server).

%% API
-export([start_link/1,
        create/1,
        call/3]).

%% gen_server callbacks
-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).

-record(state, {
    context}).

%%%===================================================================
%%% API
%%%===================================================================

call(Pid, Fun, Args) ->
  gen_server:cast(Pid, {call, Fun, Args}).

start_link(Context) ->
  gen_server:start_link(?MODULE, [Context], []).

create(Context) ->
  ev8call_sup:start_child(Context).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([Context]) ->
  {ok, #state{
      context = Context}}.

handle_call(_Request, _From, State) ->
  {stop, normal, {error, badcall}, State}.

handle_cast({call, Fun, Args}, State) ->
  Context = State#state.context,
  ev8:call_respond(Context, Fun, Args),
  {stop, normal, State}.

handle_info(_Info, State) ->
  {stop, normal, State}.

terminate({{badarity, _}, _}, State) ->
  Context = State#state.context,
  v8nif:execute(Context, self(), {call_respond, {error, badarity}}),
  ok;
terminate(normal, _State) ->
  ok;
terminate(Reason, State) when is_atom(Reason) ->
  Context = State#state.context,
  v8nif:execute(Context, self(), {call_respond, {error, Reason}});
terminate(_Reason, State) ->
  Context = State#state.context,
  v8nif:execute(Context, self(), {call_respond, {error, unknown}}),
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================