{test_files,[{computer_handler,stop},
	     {computer_handler,start},
	     {computer_handler,stop}
	    ]}.


{apps,[{{service,"dns_service"},{dir,"/home/pi/erlang/c/source"},
	{computer,"master_computer"}},
       {{service,"iaas_service"},{dir,"/home/pi/erlang/c/source"},
	{computer,"master_computer"}}]}.

{computers,[{"master_computer",'master_computer@asus',"localhost",42000},
	    {"w1_computer",'w1_computer@asus',"localhost",50001},
	    {"w2_computer",'w2_computer@asus',"localhost",50002}
	   ]}.
{source,{dir,"/home/pi/erlang/d/source"}}.
