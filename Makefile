# include .env file and export its env vars
# (-include to ignore error if it does not exist)
include .env

# deps
update   :; forge update

# Build & test
build    :; forge build
test     :; forge test --fork-url ${FORK_URL} --fork-block-number ${BLOCK_NUMBER}
report   :; forge test --fork-url ${FORK_URL} --fork-block-number ${BLOCK_NUMBER} --gas-report  | cat > .gas-report
match    :; forge test --fork-url ${FORK_URL} --fork-block-number ${BLOCK_NUMBER} -m ${MATCH} -vvv
trace    :; forge test --fork-url ${FORK_URL} --fork-block-number ${BLOCK_NUMBER} -vvv
clean    :; forge clean
snapshot :; forge snapshot --fork-url ${FORK_URL} --fork-block-number ${BLOCK_NUMBER}
