# Starflow ICO Contracts


## StarCoin Token Generation Event

StarCoin is developed on Ethereum’s blockchain and conform to the ERC20 Token Standard.

Important notes:

1. StarCoins will be sent automatically back to the wallet from which the funds have been sent.
2. StarCoin transactions will be limited till ICO end to prevent trading before the ICO ends.
3. During the pre-ICO ETH is accepted only from wallets compliant with ERC-20 token standard. (recommended to use: MyEtherWallet). Do not send ETH directly from cryptocurrency exchanges (Coinbase, Kraken, Poloniex etc.)!
4. We'll send back all ETH in case of minimal cap is not collected.

## How to setup development environment and run tests?

1. Install `docker` if you don't have it.
1. Clone this repo.
1. Run `docker-compose build --no-cache`.
1. Run `docker-compose up -d`.


Wait a little (how long?)

1. Install dependencies: `docker-compose exec workspace yarn`.
1. To run tests: `docker-compose exec workspace truffle test`.
1. To merge your contracts via sol-merger run: `docker-compose exec workspace yarn merge`.
Merged contracts will appear in `merge` directory.
