-record(computer_info,{
	  vm_name,
	  vm,
	  ip_addr,
	  port,
	  mode,
	  worker_info_list
	 }).

-define(ETS,system_ets).
