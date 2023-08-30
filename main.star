# NOTE: If you're a VSCode user, you might like our VSCode extension: https://marketplace.visualstudio.com/items?itemName=Kurtosis.kurtosis-extension

# https://docs.kurtosis.com/starlark-reference/import-module
lib = import_module("github.com/CryptoFewka/zetachain-package/lib/lib.star")
eth = import_module("github.com/kurtosis-tech/eth2-package/main.star")

#NAME_ARG = "name"
NUM_VALIDATOR_NODES = 2
NUM_FULL_NODES = 2
CHAIN_ID = "athens_101-1"
KEYRING = "test"
NETWORK_NAME = "localnet"

# For more information on...
#  - the 'run' function:  https://docs.kurtosis.com/concepts-reference/packages#runnable-packages
#  - the 'plan' object:   https://docs.kurtosis.com/starlark-reference/plan
#  - the 'args' object:   https://docs.kurtosis.com/next/concepts-reference/args
#def run(plan, args):
#    plan.print("Hello world")

def run(plan, num_validator_nodes=NUM_VALIDATOR_NODES, num_full_nodes=NUM_FULL_NODES, chain_id=CHAIN_ID, keyring=KEYRING, network_name=NETWORK_NAME):

    #name = args.get(NAME_ARG, "John Snow")

    # Grab the nginx.conf file to use when launching MetaChain Testnet in a Box.
    nginx_config = read_file(
        src = "./static-files/nginx.conf",
    )
    # Grab ethereum network_params.json for eth2-package using a relative locator
    network_params = read_file(
        src = "./static_files/eth_network_params.json",
    )

    plan.print("Building with " + num_validator_nodes + " validators, and " + num_full_nodes + " full nodes" )

    # https://docs.kurtosis.com/starlark-reference/plan#upload_files
    #config_json = plan.upload_files("github.com/CryptoFewka/zetachain-package/static-files/config.json")

    plan.print("Launching ZetaNodes for Genesis Creation")

    # Spin up NUM_VALIDATOR_NODES worth of Validator Nodes
    for i in range(1, num_validator_nodes + 1):
        #ex: lib.run_zetanode(plan,localnet-zetacore-1, entrypoint=["root/genesis.sh 2"]
        lib.run_zetanode(plan,name=str(network_name) + "-zetacore-" + str(i), entrypoint=["root/genesis.sh", str(num_validator_nodes)])

    # Spin up NUM_FULL_NODES worth of Full Nodes
    for i in range(1, num_full_nodes + 1):
        lib.run_zetanode(plan,name=str(network_name) + "-zetaclient-" + str(i), entrypoint=["root/start-zetaclientd-genesis.sh"])

    # Spin up Rosetta
    lib.run_zetanode(plan,name=str(network_name) + "-rosetta-1", entrypoint=[
        "zetacored",
        "rosetta",
        "--tendermint",
        str(network_name) + "-zetacore-1:26657",
        "--grpc",
        str(network_name) + "zetacore-1:9000",
        "--network",
        str(chain_id),
        "--blockchain",
        "zetacore"
    ])

    #Launch ETH dev net
    # See: https://github.com/kurtosis-tech/eth2-package
    # Get network_params.json and pass everything as an argument
    eth.run("github.com/kurtosis-tech/eth2-package", network_params)

    #Launch nginx
    lib.run_nginx(plan, nginx_config)


    #lib.run_hello(plan, config_json)
