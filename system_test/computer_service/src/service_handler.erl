%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%%
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(service_handler).  
 
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------


%% External exports

-export([start/6,stop/1,
	 create/6,delete/1]).


%% ====================================================================
%% External functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Function:init 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
%% start(ServiceId,{Type,Source},DestinationDir,{DnsIpAddr,DnsPort},EnvVariables)->
start(Vm,ServiceId,Type,Source,DestinationDir,EnvVariables)->
    create(Vm,ServiceId,Type,Source,DestinationDir,EnvVariables).

stop(ServiceId)->
    delete(ServiceId).
%% --------------------------------------------------------------------
%% Function:clone_compile(Service,BoardNode)
%% Description:
%% Returns: ok|{erro,compile_info}|{error,nodedown}
%% --------------------------------------------------------------------
delete(ServiceId)->
    Result=case rpc:call(node(),application,stop,[list_to_atom(ServiceId)],10000) of
	       ok->
		   PathServiceEbin=filename:join([ServiceId,"ebin"]),
		   case rpc:call(node(),code,del_path,[PathServiceEbin]) of
		       true->
			   case rpc:call(node(),os,cmd,["rm -rf "++ServiceId]) of
			       []->
				   ok;
			       Err ->
				   {error,[undefined_error,ServiceId,Err,?MODULE,?LINE]}
			   end;
		       false->
			   {error,[directory_not_found,ServiceId,?MODULE,?LINE]};
		       {error,Err}->
			   {error,[ServiceId,Err,?MODULE,?LINE]};
		       {badrpc,Err} ->
			   {error,[badrpc,ServiceId,Err,?MODULE,?LINE]};
		       Err ->
			   {error,[undefined_error,ServiceId,Err,?MODULE,?LINE]}
		   end;
	       {error,{not_started,Err}}->
		   {error,[eexists,ServiceId,Err,?MODULE,?LINE]};
	       {badrpc,Err} ->
		   {error,[badrpc,ServiceId,Err,?MODULE,?LINE]};
	       Err ->
		   {error,[undefined_error,ServiceId,Err,?MODULE,?LINE]}
	   end,
    Result.

%% --------------------------------------------------------------------
%% Function:clone_compile(Service,BoardNode)
%% Description:
%% Returns: ok|{erro,compile_info}|{error,nodedown}
%%
%% PodId/Service
%%
%%
%% --------------------------------------------------------------------
create(Vm,ServiceId,Type,Source,DestinationDir,EnvList)->
    ServiceDir=filename:join([DestinationDir,ServiceId]),
    Result =case filelib:is_dir(ServiceDir) of
		true->
		    {error,[service_already_loaded,ServiceId,?MODULE,?LINE]};
		false ->
		    case load_code(ServiceId,ServiceDir,Type,Source) of
			{error,Err}->
		    {error,Err};
			ok ->
			    case compile(ServiceId,ServiceDir) of
				{error,Err}->
				    {error,Err};
				ok ->
				    %timer:sleep(10000),
				    case start_app(Vm,ServiceId,ServiceDir,EnvList) of
					{error,Err}->
					    {error,Err};
					ok->
					    ok
				    end
			    end
		    end
	    end,
    timer:sleep(2000),
    Result.
    


%% --------------------------------------------------------------------
%% Function:clone_compile(Service,BoardNode)
%% Description:
%% Returns: ok|{erro,compile_info}|{error,nodedown}
%% --------------------------------------------------------------------
load_code(ServiceId,ServiceDir,github,UrlToSource)->
    FileName=ServiceId++".git",
    UrlToService=UrlToSource++"/"++FileName,
    os:cmd("git clone "++UrlToService++" "++ServiceDir),
    ok;

load_code(ServiceId,ServiceDir,dir,Path)->
    PathToService=filename:join(Path,ServiceId),
   % glurk=ServiceDir,
    Result=case filelib:is_dir(PathToService) of
	       true->
	%	   ok=file:make_dir(ServiceDir),
		   []=os:cmd("cp -r "++PathToService++" "++ServiceDir),
		   ok;
	       false->
		   {error,['dir eexist',PathToService,?MODULE,?LINE]}
	   end,
	       
    Result.

%% --------------------------------------------------------------------
%% Function:clone_compile(Service,BoardNode)
%% Description:
%% Returns: ok|{erro,compile_info}|{error,nodedown}
%% --------------------------------------------------------------------
compile(ServiceId,ServiceDir)->
    PathSrc=filename:join([ServiceDir,"src"]),
    PathEbin=filename:join([ServiceDir,"ebin"]),
    
    %Get erl files that shall be compiled
    Result=case file:list_dir(PathSrc) of
	       {ok,Files}->
		   FilesToCompile=[filename:join(PathSrc,File)||File<-Files,filename:extension(File)==".erl"],
		   % clean up ebin dir
		   case rpc:call(node(),os,cmd,["rm -rf "++PathEbin++"/*"]) of
		       []->
			   CompileResult=[{rpc:call(node(),c,c,[ErlFile,[{outdir,PathEbin}]],5000),ErlFile}||ErlFile<-FilesToCompile],
			   case [{R,File}||{R,File}<-CompileResult,error==R] of
			       []->
				   AppFileSrc=filename:join(PathSrc,ServiceId++".app"),
				   AppFileDest=filename:join(PathEbin,ServiceId++".app"),
				   case rpc:call(node(),os,cmd,["cp "++AppFileSrc++" "++AppFileDest]) of
				       []->
					 %  io:format("~p~n",[{AppFileSrc,AppFileDest,?FILE,?LINE}]),
					   ok;
				       {badrpc,Err} ->
					   {error,[badrpc,ServiceId,Err,?MODULE,?LINE]};
				       Err ->
					   {error,[undefined_error,ServiceId,Err,?MODULE,?LINE]}
				   end;
			       CompilerErrors->
				   {error,[compiler_error,CompilerErrors,?MODULE,?LINE]}
			   end;
		       {badrpc,Err} ->
			   {error,[badrpc,ServiceId,Err,?MODULE,?LINE]};
		       Err ->
			   {error,[undefined_error,ServiceId,Err,?MODULE,?LINE]}
		   end;
	       {badrpc,Err} ->
		   {error,[badrpc,ServiceId,Err,?MODULE,?LINE]};
	       Err ->
		   {error,[undefined_error,ServiceId,Err,?MODULE,?LINE]}
	   end,
    Result.

%% --------------------------------------------------------------------
%% Function:clone_compile(Service,BoardNode)
%% Description:
%% Returns: ok|{erro,compile_info}|{error,nodedown}
%% --------------------------------------------------------------------
start_app(Vm,ServiceId,ServiceDir,EnvList)->
    PathServiceEbin=filename:join([ServiceDir,"ebin"]),
    Result = case rpc:call(Vm,code,add_path,[PathServiceEbin],5000) of
		 true->
		     Service=list_to_atom(ServiceId),
		     ok=rpc:call(Vm,application,set_env,[[{Service,EnvList}]]),
		     case rpc:call(Vm,application,start,[Service],5000) of
			 ok->
			     ok;
			 {badrpc,Err} ->
			     {error,[badrpc,ServiceId,Err,?MODULE,?LINE]};
			 {error,{already_started,Service}}->
			     ok;  % Needs to be checked 
			 Err->
			     {error,[undefined_error,ServiceId,Err,?MODULE,?LINE]}
		     end;
		 {badrpc,Err} ->
		     {error,[badrpc,ServiceId,Err,?MODULE,?LINE]};
		 Err ->
		     {error,[undefined_error,ServiceId,Err,?MODULE,?LINE]}
	     end,
    Result.
