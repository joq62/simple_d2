%%% -------------------------------------------------------------------
%%% Author  : Joq Erlang
%%% Description :computer_service
%%% Manage the Pods on the computer 
%%% Implements: local_dns
%%% Key Datastructures
%%% ComputerPort: computer_service listen port
%%% application:set_env(computer_service,[{computer_ip_address_port,{ComputerAddress,ComputerPort},
%%%                                       {dns_port,DnsPort}])),
%%% 
%%% ListofPods=[{pod,PodId,[IpAddr,Port]},,,]
%%%
%%% setPod(PodId,{IpAddr,Port})->ok|{error,[Error,,,]}
%%% getPod(PodNode)-> {IpAddr,Port}|{error,[Error,,,]}
%%% getAllActivePodAddresses()->[{IpAddr,Port},,,]
%%% pod_info()->ListOfPods
%%% 
%%% LocalDnsList=[{ServiceId,IpAddr,Port}
%%% setLocalDnsList(DnsList)->ok
%%% getLocalDnsList()->DnsList
%%% getLocalDnsServiceAddresses(ServiceId)-> []|[{IpAddr,Port},,,]
%%% 
%%%    
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(computer_service). 

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-define(NODES_CONFIG,"nodes.config").
-define(POLL_INTERVAL,1*1000).

%% --------------------------------------------------------------------
 
%% --------------------------------------------------------------------
%% Key Data structures
%% 
%% --------------------------------------------------------------------
-record(state,{computer_ip_address_port,
	       pod_list, 
	       dns_ip_address_port,
	       dns_list
	      }).


	  
%% --------------------------------------------------------------------

%% ====================================================================
%% External functions
%% ====================================================================
%%% create_pod({IpAddr,Port})->ok|{error,[Error,,,]}
%%% delete_pod({IpAddr,Port})->ok|{error,[Error,,,]}
%%% get_all_pod_addresses()->[{IpAddr,Port},,,]
%%% get_pod_list()->ListOfPods
%%% 
%%% LocalDnsList=[{ServiceId,IpAddr,Port}
%%% set_dns_list(DnsList)->ok
%%% get_dns_list()->DnsList
%%% get_service_addresses(ServiceId)-> []|[{IpAddr,Port},,,]

-export([ping/0]).

-export([create_pod/1,delete_pod/1,
	 get_all_pod_addresses/0,
	 get_pod_list/0	 
	]).

-export([set_dns_list/1,get_dns_list/0,
	 get_service_addresses/1
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
create_pod({IpAddr,Port})->
    gen_server:call(?MODULE,{create_pod,{IpAddr,Port}},infinity).
delete_pod({IpAddr,Port})->
    gen_server:call(?MODULE,{delete_pod,{IpAddr,Port}},infinity).

get_all_pod_addresses()->
    gen_server:call(?MODULE,{get_all_pod_addresses},infinity).
get_pod_list()->
    gen_server:call(?MODULE,{get_pod_list},infinity).
get_dns_list()->
    gen_server:call(?MODULE,{get_dns_list},infinity).
get_service_addresses(ServiceId)->
    gen_server:call(?MODULE,{get_service_addresses,ServiceId},infinity).

ping()->
    gen_server:call(?MODULE,{ping},infinity).

%%------------------ cast ---------------------------------------------


set_dns_list(DnsList)->
    gen_server:cast(?MODULE,{set_dns_list,DnsList}).


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
    {ok,{DnsPort}}=application:get_env(computer_ip_address_port),
    
    {ok, #state{computer_ip_address_port={ComputerAddress,ComputerPort},
		pod_list=[], 
		dns_ip_address_port={"localhost",DnsPort},
		dns_list=[]}}.

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
handle_call({ping}, _From, State) ->
    Reply={pong,node(),?MODULE},
    {reply, Reply, State};

handle_call({create_pod,{IpAddr,Port}}, _From, State) ->
    Reply={IpAddr,Port},
    {reply, Reply, State};
handle_call({delete_pod,{IpAddr,Port}}, _From, State) ->
    Reply={IpAddr,Port},
    {reply, Reply, State};
handle_call({get_all_pod_addresses}, _From, State) ->
     Reply=glurk,
    {reply, Reply, State};

handle_call({get_pod_list}, _From, State) ->
      Reply=glurk,
    {reply, Reply, State};

handle_call({get_service_addresses,ServiceId}, _From, State) ->
      Reply=ServiceId,
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

handle_cast({set_dns_list,DnsList},State) ->
    
    {noreply, State#state{dns_list=DnsList}};

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
