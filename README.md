# Preview Lil Nouns
Code for [Preview Lil Nouns](https://glittering-torrone-f2b6e2.netlify.app/).

## Sub projects
See the documentation for the individual sub projects [contracts/](https://github.com/nvonpentz/lil-nouns-preview/tree/master/contracts) and [frontend/](https://github.com/nvonpentz/lil-nouns-preview/tree/master/frontend).

## Install
Run the install scripts for both ./contracts/ and ./frontend.
```
npm run install
```

## Running
Follow the instructions in contracts/README, and frontend/README.

Using .env.example as a template create the necessary secrets, add them to a .env file, and source it.
```
source .env
```

Start local blockchain node
```
npm run start-rpc
```

Build the contracts
```
npm run build-contracts
```

Deploy the contracts to the local blockchain node
```
npm run deploy
```

Start the react frontend
```
npm run start-frontend
```

See package.json for other scripts.
