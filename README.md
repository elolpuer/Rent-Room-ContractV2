# Rent-Room-ContractV2
Smart Contract allows you to rent property throught blockchain.
The ERC721 token extension(ERC721Rentable) written by me is used here.
This is improved version of my first smart contract. In the first version there was a lot of mistakes such as storing keys on blockchain without hashing, re-entry, etc.
Also this version is upgradeable. To check this you can run tests with command `npx hardhat test` or `yarn hardhat test`.This test upgrade RentV1 to RentV2. The second version adds payment with ERC20 tokens.
