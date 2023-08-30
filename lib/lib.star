def run_nginx(plan, nginx_config):
    # https://docs.kurtosis.com/starlark-reference/plan#add_service
    plan.add_service(
        name = "nginx",
        config = ServiceConfig(
            image = "nginx:latest",
    	    ports = {
                "REST": PortSpec(number = 1317, wait = "2m"),
                "RPC": PortSpec(number = 9545, wait = "2m"),
                "WEBSOCKET": PortSpec(number = 9545, wait = "2m")
            },
            files = {
                "/eth/nginx/": nginx_config
            },
        )
    )

def run_zetanode(plan, name="zetachain-node", entrypoint=[], ports={}, files={}):
    # See https://docs.kurtosis.com/starlark-reference/plan#add_service
    plan.add_service(
        config = ServiceConfig(
	    # See https://docs.kurtosis.com/starlark-reference/service-config
            image = "zetanode:latest", #TODO: add optional image param rather than hardcode of latest.
            ports,
    	    #ports = {
            #   "RPC": PortSpec(number = 8546, wait = "2m"),
            #   "WEBSOCKET": PortSpec(number = 8546, wait = "2m")
            #},
            entrypoint,
            #entrypoint = [
            #    "/root/genesis.sh", 
            #    num_nodes
            #],
            files,
            #files = {
            #    "path/to/files/artifact_1/": files_artifact_1,
            #    "path/to/files/artifact_2/": Directory(
            #        artifact_name=files_artifact_2,
            #    ),
            #    "path/to/persistent/directory/": Directory(
            #        persistent_key="data-directory",
            #    ),
            #},
        )
    )
