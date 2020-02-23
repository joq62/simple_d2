%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%%
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(local_computer_service_test). 
    
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
%-include_lib("eunit/include/eunit.hrl").
% -include("test_src/common_macros.hrl").
%% --------------------------------------------------------------------

%% External exports
-export([start/0
	]).
     
-compile(export_all).



%% ====================================================================
%% External functions
%% ====================================================================
start()->
    ok=rpc:call(node(),?MODULE,init_test,[],10*1000),
    ok=rpc:call(node(),?MODULE, start_computer_test,[],60*1000),
    stop_test(),
    ok.

init_test()->
    ToKill= ["20010_vm",
	     "20011_vm",
	     "20012_vm",
	     "20013_vm",
	     "20014_vm",
	     "20015_vm",
	     "20016_vm",
	     "20017_vm",
	     "20018_vm",
	     "20019_vm"],
    [vm_handler:delete(VmId)||VmId<-ToKill],
    []=nodes(),
    file:make_dir("tabort1"),
    file:make_dir("tabort2"),
    file:open("fil1",[write]),
    file:open("fil2",[write]),
    Files=["tabort1","tabort2","fil1","fil1"],
    [true,true,true,true]=[filelib:is_file(File)||File<-Files],
    ok.

start_computer_test()->
    ok=application:set_env([{computer_service,[{computer_ip_address_port,{"localhost",40000}},
					       {min_vm_port,20010},{max_vm_port,20011},
					       {type,github},{source,"https://github.com/joq62"}
					      ]
			     }
			   ]),
    ok=application:start(computer_service),
     io:format(" ~p~n",[{?MODULE,?LINE}]),
    {state,{"localhost",40000},20010,20011,github,"https://github.com/joq62",
     [{"20010_vm",'20010_vm@asus',20010},{"20011_vm",'20011_vm@asus',20011}],
     [{"tcp_service","localhost",40000},{"tcp_service","localhost",20010},{"tcp_service","localhost",20011},
      {"log_service","localhost",40000},{"log_service","localhost",20010},{"log_service","localhost",20011},
      {"local_dns_service","localhost",40000},{"local_dns_service","localhost",20010},{"local_dns_service","localhost",20011}
     ]}=computer_service:state_info(),
    
    Files=["tabort1","tabort2","fil1","fil1"],
    [false,false,false,false]=[filelib:is_file(File)||File<-Files],
    ok.

ping_test()->
    
    {state,{_IpAddr,_Port},
     VmMinPort,VmMaxPort,
     Type,Source,[],[]}=computer_service:state_info(),

    {ok,VmStartInfo}=lib_computer:start_vms(VmMinPort,VmMaxPort-VmMinPort,[]),
    [{'20010_vm@asus',pong},
     {'20011_vm@asus',pong}
     ]=[{Vm,net_adm:ping(Vm)}||{_VmId,Vm,_Port}<-VmStartInfo],
    ok.
%% ------------ Start Services ---------------------------------------------------------
start_20010_local_dns_service_test_XXX()->
    {state,{IpAddr,Port},
     _VmMinPort,_VmMaxPort,
     Type,Source,[],[]}=computer_service:state_info(),
    {ok,"local_dns_service"}=service_handler:start('20010_vm@asus',"local_dns_service",Type,Source,"20010_vm",[]),
    {pong,'20010_vm@asus',local_dns_service}=rpc:call('20010_vm@asus',local_dns_service,ping,[]),
    ok.

start_20010_log_service_test_xxxx()->
    {state,{IpAddr,Port},
     _VmMinPort,_VmMaxPort,
     Type,Source,[],[]}=computer_service:state_info(),
    
    {ok,"log_service"}=service_handler:start('20010_vm@asus',"log_service",Type,Source,"20010_vm",[]),
    {pong,'20010_vm@asus',log_service}=rpc:call('20010_vm@asus',log_service,ping,[]),
    ok.

start_20010_tcp_service_test_XXXX()->
    {state,{IpAddr,Port},
     _VmMinPort,_VmMaxPort,
     Type,Source,[],[]}=computer_service:state_info(),
    {ok,"tcp_service"}=service_handler:start('20010_vm@asus',"tcp_service",Type,Source,"20010_vm",[]),
    {pong,'20010_vm@asus',tcp_service}=rpc:call('20010_vm@asus',tcp_service,ping,[]),
    
    ok.

scratch_computer_test_XXXXX()->
    file:make_dir("tabort1"),
    file:make_dir("tabort2"),
    file:open("fil1",[write]),
    file:open("fil2",[write]),
    Files=["tabort1","tabort2","fil1","fil1"],
    [true,true,true,true]=[filelib:is_file(File)||File<-Files],
    lib_computer:scratch(),
    [false,false,false,false]=[filelib:is_file(File)||File<-Files],
   ok.
    
    

stop_computer_test()->
    
    application:stop(computer_service),
    application:unload(computer_service),
    ok.

%%---------------------------------------------------------------------------------


stop_test()->
  %  []=os:cmd("rm -r "++"_service"),
  %  []=os:cmd("rm -r "++"divi_service"),
%    ok=pod_service:stop_unload("divi_service"),
 %   ok=pod_service:stop_unload("adder_service"),
  %  ok=pod_service:stop_unload("log_service"),
  %  application:stop(pod_service),
    kill().

kill()->
    init:stop().
