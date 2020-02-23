%% This is the application resource file (.app file) for the 'base'
%% application.
{application, pod_service,
[{description, "pod_service" },
{vsn, "0.0.1" },
{modules, [pod_service_app,pod_service_sup,
	   pod_service,lib_pod]},
{registered,[pod_service]},
{applications, [kernel,stdlib]},
{mod, {pod_service_app,[]}},
{start_phases, []}
]}.
