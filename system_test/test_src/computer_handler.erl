%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%%
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(computer_handler). 
  
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
% -include_lib("eunit/include/eunit.hrl").

%% --------------------------------------------------------------------

%% External exports
-export([start/0,
	 
	 stop/0
	]).

%-compile(export_all).

-define(TIMEOUT,1000*15).

%% ====================================================================
%% External functions
%% ====================================================================
% ComputerList=[{"master_computer",'master_computer@asus',"localhost",42000},
%  {"w1_computer",'w1_computer@asus',"localhost",42001},
%  {"w2_computer",'w2_computer@asus',"localhost",42002}]
% LibService=[{{service,"libservice_service"},{dir,"/home/pi/erlang/c/source"}}]
% AppList={{service,"iaas_service"},{dir,"/home/pi/erlang/c/source"},{computer,"master_computer",'master_computer@asus'}}

start()->
    io:format(" ~n"),
    io:format("~p",[time()]),
    io:format(" Test started :~p~n",[{?MODULE,start}]),
    io:format(" ~n"),
    %%--------------- Start computer_service ----------------------
    ok=application:set_env([{computer_service,[{computer_ip_address_port,{"localhost",40000}},
					       {min_vm_port,40010},{max_vm_port,40010},
					       {type,dir},{source,"/home/pi/erlang/d/source"}
					      ]
			     }
			   ]),
    ok=application:start(computer_service),
    computer_service:state_info(),
    [{computers,ComputerList}]=system_test:get(computers),
    [{source,{Type,Source}}]=system_test:get(source),
    {pong,'40010_vm@asus',log_service}=tcp_service:call({"localhost",40010},{log_service,ping,[]}),
    
    VmStartR=[start_vm_computer_service(NodeId,Node,IpAddr,Port,Type,Source,"computer_service")||{NodeId,Node,IpAddr,Port}<-ComputerList],
    
  %  io:format("~p~n",[{VmStartR,?MODULE,?LINE}]),   

    io:format(" ~n"),
    io:format("~p",[time()]),
    io:format("  OK :~p~n",[{?MODULE,start}]),
    io:format(" ~n"),
    ok.

stop()->
    io:format(" ~n"),
    io:format("~p",[time()]),
    io:format(" Test started :~p~n",[{?MODULE,stop}]),
    io:format(" ~n"),

    [{computers,ComputerList}]=system_test:get(computers),	
    timer:sleep(20000),
    VmStopR=[vm_handler:delete(NodeId)||{NodeId,_Node,_IpAddr,_Port}<-ComputerList],
    io:format("~p~n",[{VmStopR,?MODULE,?LINE}]),   

    io:format(" ~n"),
    io:format("~p",[time()]),
    io:format("  OK :~p~n",[{?MODULE,stop}]),
    io:format(" ~n"), 
   ok.
    

%% --------------------------------------------------------------------
%% Function:init 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
start_vm_computer_service(VmId,Vm,IpAddr,Port,Type,Source,ServiceId)->
    vm_handler:create(VmId),
    ServiceDir=filename:join(VmId,ServiceId),
    ok=file:make_dir(ServiceDir),
    []=os:cmd("cp -r "++ServiceId++"/* "++ServiceDir),
    Ebin=filename:join(ServiceDir,"ebin"),
    rpc:call(Vm,code,add_path,[Ebin],5000),
    
    ok=rpc:call(Vm,application,set_env,[[{computer_service,[{computer_ip_address_port,{IpAddr,Port}},
							    {min_vm_port,20010},{max_vm_port,20011},
							    {type,Type},{source,Source}
							   ]
					 }
					]
				       ]),
    ok=rpc:call(Vm,application,start,[list_to_atom(ServiceId)]),
    ok.
