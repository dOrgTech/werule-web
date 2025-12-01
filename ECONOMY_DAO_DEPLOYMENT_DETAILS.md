# Economy DAO Deployment Details

## Important: Owner-Only Restriction

The current TrustlessFactory has `onlyOwner` on all 3 deployment functions. Only the factory owner (`0x06E5b15Bc39f921e1503073dBb8A5dA2Fc6220E9`) can deploy Economy DAOs.

**This needs to be changed if you want public users to deploy Economy DAOs from the web app.**

---

## Contract Addresses (Etherlink Testnet)

```
TrustlessFactory:        0xFB3dE5d465264557464950a9E824eBf1acc33394
NativeProject Impl:      0x5D1bd30F5D49Ea69a3778704EA444ee6ede254Df
ERC20Project Impl:       0x9E10B1c2c674424759890e1BdD00828ADa21C7c9
InfrastructureFactory:   0xEFaaBDdd399cB773efadE356Ef86E218D7138C8B
DAOFactory:              0x7da852580EE82F20c8d53E9aEEb7Cb0fE6291B6b
EconomyFactory:          0x8477A42129C830a1C6eFB91f703e966109dec8C1
RepTokenFactory:         0x94c42d88f074028Fa84d173A539be88D2500834B
```

---

## Successful Deployment Transaction Details

### Step 1: deployInfrastructure

**Function Signature:**
```solidity
function deployInfrastructure(uint48 timelockDelayInMinutes) external onlyOwner
```

**Call Data:**
- `timelockDelayInMinutes`: `2` (2 minutes for testing)

**ABI Encoded:**
```
Function: deployInfrastructure(uint48)
Selector: 0x... (compute from ABI)
Parameters:
  - timelockDelayInMinutes: 2
```

**Result (from InfrastructureDeployed event):**
```
Economy:   0x1Ec188257C614008d7dd8AaF1D427B7cbde33561
Registry:  0xF61Fa2779CdD2693dAf97b297317429D6e127c3D
Timelock:  0xc848B55C9f37636270E4c372a504E29f0CB9D075
```

---

### Step 2: deployDAOToken

**Function Signature:**
```solidity
function deployDAOToken(
    address registryAddr,
    address timelockAddr,
    TokenParams calldata tokenParams,
    GovParams calldata govParams
) external onlyOwner
```

**Structs:**
```solidity
struct TokenParams {
    string name;
    string symbol;
    address[] initialMembers;
    uint256[] initialAmounts;
}

struct GovParams {
    string name;
    uint48 timelockDelay;      // in blocks
    uint32 votingPeriod;       // in blocks
    uint256 proposalThreshold; // in wei
    uint8 quorumFraction;      // percentage (0-100)
}
```

**Call Data:**
```javascript
{
  registryAddr: "0xF61Fa2779CdD2693dAf97b297317429D6e127c3D",
  timelockAddr: "0xc848B55C9f37636270E4c372a504E29f0CB9D075",
  tokenParams: {
    name: "Test Economy DAO Token",
    symbol: "TEDT",
    initialMembers: [
      "0x06E5b15Bc39f921e1503073dBb8A5dA2Fc6220E9",
      "0x6E147e1D239bF49c88d64505e746e8522845D8D3"
    ],
    initialAmounts: [
      "100000000000000000000",  // 100 * 10^18 (100 tokens)
      "50000000000000000000"    // 50 * 10^18 (50 tokens)
    ]
  },
  govParams: {
    name: "Test Economy DAO Governor",
    timelockDelay: 1,                        // 1 block
    votingPeriod: 50400,                     // ~1 week in blocks
    proposalThreshold: "10000000000000000000", // 10 * 10^18 (10 tokens)
    quorumFraction: 4                        // 4%
  }
}
```

**Result (from DAOTokenDeployed event):**
```
RepToken:  0x97AfD76289BC1b9d686e41Ad204d6e67106b1078
DAO:       0x052b2C6227c0448323ae51FeA08713594eb9Ad39
```

---

### Step 3: configureAndFinalize

**Function Signature:**
```solidity
function configureAndFinalize(
    AddressParams calldata addressParams,
    EconomyParams calldata economyParams
) external onlyOwner
```

**Structs:**
```solidity
struct AddressParams {
    address[2] implAddresses;     // [nativeProjectImpl, erc20ProjectImpl]
    address[5] contractAddresses; // [economy, registry, timelock, repToken, dao]
}

struct EconomyParams {
    uint initialPlatformFeeBps;    // basis points (250 = 2.5%)
    uint initialAuthorFeeBps;      // basis points (500 = 5%)
    uint initialCoolingOffPeriod;  // seconds
    uint initialBackersQuorumBps;  // basis points (5100 = 51%)
    uint initialProjectThreshold;  // wei
    uint initialAppealPeriod;      // seconds
}
```

**Call Data:**
```javascript
{
  addressParams: {
    implAddresses: [
      "0x5D1bd30F5D49Ea69a3778704EA444ee6ede254Df",  // NativeProject impl
      "0x9E10B1c2c674424759890e1BdD00828ADa21C7c9"   // ERC20Project impl
    ],
    contractAddresses: [
      "0x1Ec188257C614008d7dd8AaF1D427B7cbde33561",  // Economy (from step 1)
      "0xF61Fa2779CdD2693dAf97b297317429D6e127c3D",  // Registry (from step 1)
      "0xc848B55C9f37636270E4c372a504E29f0CB9D075",  // Timelock (from step 1)
      "0x97AfD76289BC1b9d686e41Ad204d6e67106b1078",  // RepToken (from step 2)
      "0x052b2C6227c0448323ae51FeA08713594eb9Ad39"   // DAO (from step 2)
    ]
  },
  economyParams: {
    initialPlatformFeeBps: 250,              // 2.5%
    initialAuthorFeeBps: 500,                // 5%
    initialCoolingOffPeriod: 259200,         // 3 days in seconds
    initialBackersQuorumBps: 5100,           // 51%
    initialProjectThreshold: "10000000000000000000",  // 10 * 10^18 (10 tokens)
    initialAppealPeriod: 604800              // 7 days in seconds
  }
}
```

**Events Emitted:**
1. `SuiteConfigured(deployer, economy, registry, timelock, repToken, dao)`
2. `NewDaoCreated(dao, token, initialMembers, initialAmounts, name, symbol, description, executionDelay, registry, keys, values)`

---

## Full ABI for TrustlessFactory

```json
[
  {
    "inputs": [
      {"internalType": "uint48", "name": "timelockDelayInMinutes", "type": "uint48"}
    ],
    "name": "deployInfrastructure",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {"internalType": "address", "name": "registryAddr", "type": "address"},
      {"internalType": "address", "name": "timelockAddr", "type": "address"},
      {
        "components": [
          {"internalType": "string", "name": "name", "type": "string"},
          {"internalType": "string", "name": "symbol", "type": "string"},
          {"internalType": "address[]", "name": "initialMembers", "type": "address[]"},
          {"internalType": "uint256[]", "name": "initialAmounts", "type": "uint256[]"}
        ],
        "internalType": "struct TrustlessFactory.TokenParams",
        "name": "tokenParams",
        "type": "tuple"
      },
      {
        "components": [
          {"internalType": "string", "name": "name", "type": "string"},
          {"internalType": "uint48", "name": "timelockDelay", "type": "uint48"},
          {"internalType": "uint32", "name": "votingPeriod", "type": "uint32"},
          {"internalType": "uint256", "name": "proposalThreshold", "type": "uint256"},
          {"internalType": "uint8", "name": "quorumFraction", "type": "uint8"}
        ],
        "internalType": "struct TrustlessFactory.GovParams",
        "name": "govParams",
        "type": "tuple"
      }
    ],
    "name": "deployDAOToken",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "components": [
          {"internalType": "address[2]", "name": "implAddresses", "type": "address[2]"},
          {"internalType": "address[5]", "name": "contractAddresses", "type": "address[5]"}
        ],
        "internalType": "struct TrustlessFactory.AddressParams",
        "name": "_addressParams",
        "type": "tuple"
      },
      {
        "components": [
          {"internalType": "uint256", "name": "initialPlatformFeeBps", "type": "uint256"},
          {"internalType": "uint256", "name": "initialAuthorFeeBps", "type": "uint256"},
          {"internalType": "uint256", "name": "initialCoolingOffPeriod", "type": "uint256"},
          {"internalType": "uint256", "name": "initialBackersQuorumBps", "type": "uint256"},
          {"internalType": "uint256", "name": "initialProjectThreshold", "type": "uint256"},
          {"internalType": "uint256", "name": "initialAppealPeriod", "type": "uint256"}
        ],
        "internalType": "struct TrustlessFactory.EconomyParams",
        "name": "_economyParams",
        "type": "tuple"
      }
    ],
    "name": "configureAndFinalize",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "anonymous": false,
    "inputs": [
      {"indexed": false, "internalType": "address", "name": "economy", "type": "address"},
      {"indexed": false, "internalType": "address", "name": "registry", "type": "address"},
      {"indexed": false, "internalType": "address", "name": "timelock", "type": "address"}
    ],
    "name": "InfrastructureDeployed",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {"indexed": false, "internalType": "address", "name": "repToken", "type": "address"},
      {"indexed": false, "internalType": "address", "name": "dao", "type": "address"}
    ],
    "name": "DAOTokenDeployed",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {"indexed": false, "internalType": "address", "name": "deployer", "type": "address"},
      {"indexed": true, "internalType": "address", "name": "economy", "type": "address"},
      {"indexed": false, "internalType": "address", "name": "registry", "type": "address"},
      {"indexed": false, "internalType": "address", "name": "timelock", "type": "address"},
      {"indexed": true, "internalType": "address", "name": "repToken", "type": "address"},
      {"indexed": true, "internalType": "address", "name": "dao", "type": "address"}
    ],
    "name": "SuiteConfigured",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {"indexed": true, "internalType": "address", "name": "dao", "type": "address"},
      {"indexed": false, "internalType": "address", "name": "token", "type": "address"},
      {"indexed": false, "internalType": "address[]", "name": "initialMembers", "type": "address[]"},
      {"indexed": false, "internalType": "uint256[]", "name": "initialAmounts", "type": "uint256[]"},
      {"indexed": false, "internalType": "string", "name": "name", "type": "string"},
      {"indexed": false, "internalType": "string", "name": "symbol", "type": "string"},
      {"indexed": false, "internalType": "string", "name": "description", "type": "string"},
      {"indexed": false, "internalType": "uint256", "name": "executionDelay", "type": "uint256"},
      {"indexed": false, "internalType": "address", "name": "registry", "type": "address"},
      {"indexed": false, "internalType": "string[]", "name": "keys", "type": "string[]"},
      {"indexed": false, "internalType": "string[]", "name": "values", "type": "string[]"}
    ],
    "name": "NewDaoCreated",
    "type": "event"
  }
]
```

---

## Option to Remove onlyOwner Restriction

If you want anyone to deploy Economy DAOs, you need to either:

1. **Remove `onlyOwner`** from the 3 functions in TrustlessFactory.sol and redeploy
2. **Or create a new permissionless wrapper** that calls the factory (factory would need to whitelist it)

Let me know if you want me to modify the contract and redeploy!
