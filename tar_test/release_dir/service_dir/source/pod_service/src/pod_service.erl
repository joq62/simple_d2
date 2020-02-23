%%% -------------------------------------------------------------------
%%% Author  : Joq Erlang
%%% Description :pod_service
%%% Controls containers (erlang applications) and provides log service 
%%% 
%%% Key Datastructures
%%% Computer: {"localhost",ComputerPort}
%%% application:set_env(computer_service,[{pod_ip_address_port,{PodAddress,PodPort},
%%%                                       {dns_port,DnsPort}])),
%%% 
%%% ListofContainers=[{ServiceId,Vsn}]
%%%
%%% load_start(ServiceId,Vsn)->ok|{error,[Error,,,]}
%%% stop_unload(ServiceId,Vsn)-> ok|{error,[Error,,,]}
%%% getAllContainers()->[{ServiceId,Vsn},,,]
%%% 
%%%    
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(pod_service). 

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
 
%% --------------------------------------------------------------------
%% Key Data structures
%% 
%% --------------------------------------------------------------------
-record(state,{computer_ip_address_port,
	       pod_ip_address_port,
	       dns_ip_address_port,
	       container_list
	      }).


	  
%% --------------------------------------------------------------------

%% ====================================================================
%% External functions
%% ====================================================================
%%% load_start(ServiceId)->ok|{error,[Error,,,]}
%%% stop_unload(ServiceId)-> ok|{error,[Error,,,]}
%%% load_start(ServiceId,Vsn)->ok|{error,[Error,,,]}
%%% stop_unload(ServiceId,Vsn)-> ok|{error,[Error,,,]}
%%% getAllContainers()->[{ServiceId,Vsn},,,]
%%% 

-export([ping/0]).

-export([load_start/1,stop_unload/1,
	 get_all_containers/0
	 
	]).

-export([
	]).

-export([start/0,
	 stop/0
	 ]).
 
%% gen_server callbacks
-export([init/1, handle_call/3,handle_cast/2, handle_info/2, terminate/2, code_change/3]).


%% ====================================================================
%% External functions
%% ====================================================================

%% Asynchrounus Signals

%% Gen server function

start()-> gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
stop()-> gen_server:call(?MODULE, {stop},infinity).


%%----------------------------------------------------------------------
load_start(ServiceId)->
    gen_server:call(?MODULE,{load_start,ServiceId},infinity).
stop_unload(ServiceId)->
    gen_server:call(?MODULE,{stop_unload,ServiceId},infinity).

get_all_containers()->
    gen_server:call(?MODULE,{get_all_containers},infinity).

ping()->
    gen_server:call(?MODULE,{ping},infinity).

%%------------------ cast ---------------------------------------------


%% ====================================================================
%% Server functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%
%% --------------------------------------------------------------------
init([]) ->
    {ok,{ComputerAddress,ComputerPort}}=application:get_env(computer_ip_address_port),
    {ok,{PodAddress,PodPort}}=application:get_env(pod_ip_address_port),
    {ok,{DnsAddress,DnsPort}}=application:get_env(dns_ip_address_port),
    
    {ok, #state{computer_ip_address_port={ComputerAddress,ComputerPort},
		pod_ip_address_port={PodAddress,PodPort},
		dns_ip_address_port={DnsAddress,DnsPort},
	        container_list=[]}}.

%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (aterminate/2 is called)
%% --------------------------------------------------------------------
handle_call({load_start,ServiceId}, _From, State) ->
    Reply=case lists:keymember(ServiceId,1,State#state.container_list) of
	      true->
		  NewState=State,
		  {error,[already_started,ServiceId,?MODULE,?LINE]};
	      false->
		  case lib_pod:start(ServiceId,State#state.dns_ip_address_port) of
		      {ok,ServiceId}->
			  NewContainerList=[{ServiceId,State#state.computer_ip_address_port}
					    |State#state.container_list],
			  NewState=State#state{container_list=NewContainerList},
			  ok;
		      {error,Err} ->
			  NewState=State,
			  {error,Err}
		  end
	  end,
									  
    {reply, Reply, NewState};
handle_call({stop_unload,ServiceId}, _From, State) ->
    Reply=case lists:keymember(ServiceId,1,State#state.container_list) of
	      false->
		  NewState=State,
		  {error,[not_loaded,ServiceId,?MODULE,?LINE]};
	      true->
		  case lib_pod:stop(ServiceId) of
		      ok->
			  NewContainerList=lists:keydelete(ServiceId,1,State#state.container_list),
			  NewState=State#state{container_list=NewContainerList},
			  ok;
		      {error,Err} ->
			  NewState=State,
			  {error,Err}
		  end
	  end,
    {reply, Reply, NewState};

handle_call({get_all_containers}, _From, State) ->
     Reply=State#state.container_list,
    {reply, Reply, State};

%%----------------------------------------------------------------------
handle_call({ping}, _From, State) ->
    Reply={pong,node(),?MODULE},
    {reply, Reply, State};

handle_call({stop}, _From, State) ->
    {stop, normal, shutdown_ok, State};

handle_call(Request, From, State) ->
    Reply = {unmatched_signal,?MODULE,?LINE,Request,From},
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------

handle_cast(Msg, State) ->
    io:format("unmatched match cast ~p~n",[{?MODULE,?LINE,Msg}]),
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)

handle_info(Info, State) ->
    io:format("unmatched match info ~p~n",[{?MODULE,?LINE,Info}]),
    {noreply, State}.


%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------
%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Internal functions
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Internal functions
%% --------------------------------------------------------------------
