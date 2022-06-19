set -ex

dfx identity new droute_test --disable-encryption || true
dfx identity use droute_test

ADMIN_PRINCIPAL=$(dfx identity get-principal)
ADMIN_ACCOUNTID=$(dfx ledger account-id)

echo $ADMIN_PRINCIPAL
echo $ADMIN_ACCOUNTID

dfx canister create test_runner

TEST_RUNNER_CANISTER_ID=$(dfx canister id test_runner)
TEST_RUNNER_ACCOUNT_ID=$(python3 principal_to_accountid.py $TEST_RUNNER_CANISTER_ID)

dfx build test_runner


dfx canister install test_runner --mode=reinstall 


# dfx canister call test_runner test


