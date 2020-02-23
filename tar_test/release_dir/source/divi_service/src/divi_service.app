%% This is the application resource file (.app file) for the 'base'
%% application.
{application, divi_service,
[{description, "divi_service  " },
{vsn, "1.0.0" },
{modules, 
	  [divi_service_app,divi_service_sup,divi_service]},
{registered,[divi_service]},
{applications, [kernel,stdlib]},
{mod, {divi_service_app,[]}},
{start_phases, []}
]}.
