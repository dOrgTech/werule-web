# DAO Deployment Guide

This guide explains how to deploy the three types of DAOs supported by the Homebase platform and the expected Firestore data structure for each.

## Overview

The platform supports three governance token types:

1. **Non-Transferable Token** - Standard governance tokens that cannot be traded
2. **Transferable Token** - Governance tokens that can be freely transferred
3. **Wrapped ERC20 Token** - Wraps an existing ERC20 token for governance (inherits decimals)

## Factory Contract Addresses

Factory addresses are stored in Firestore at `contracts/{network}`:

- `wrapper` or `wrapper_jurisdiction` - Non-transferable token factory
- `wrapper_t` - Transferable token factory
- `wrapper_w` - Wrapped ERC20 token factory
- `wrapper_trustless` - Trustless economy DAO factory

Network values:
- Mainnet: `Etherlink`
- Testnet: `Etherlink-Testnet`
- Localhost: `Localhost`

---

## 1. Non-Transferable Token DAO

### Contract
Use factory at Firestore: `contracts/{network}/wrapper` or `contracts/{network}/wrapper_jurisdiction`

### Deployment Function
```solidity
function deployDAO(DaoParams memory params) public payable

struct DaoParams {
    address[] initialMembers;
    uint256[] initialAmounts;
    string name;
    string symbol;
    string description;
    uint256 executionDelay;
    address admin;
    string[] keys;
    string[] values;
}
```

### JavaScript Example
```javascript
const factory = await ethers.getContractAt('StandardFactory', factoryAddress);

await factory.deployDAO({
    initialMembers: ['0xAddress1', '0xAddress2'],
    initialAmounts: [ethers.parseEther('1000'), ethers.parseEther('500')],
    name: 'My DAO',
    symbol: 'MDAO',
    description: 'A governance DAO',
    executionDelay: 86400,  // 1 day in seconds
    admin: deployerAddress,
    keys: [],
    values: []
});
```

### Event Emitted
```solidity
event NewDaoCreated(
    address indexed dao,
    address indexed token,
    address[] initialMembers,
    uint256[] initialAmounts,
    string name,
    string symbol,
    string description,
    uint256 executionDelay,
    address indexed admin,
    string[] keys,
    string[] values
);
```

### Firestore Structure
Collection: `idaos{Network}` (e.g., `idaosEtherlink-Testnet`)

Document ID: `{daoAddress}`

```javascript
{
    name: string,
    symbol: string,
    description: string,
    address: string,              // DAO contract address
    token: string,                // Governance token address
    govTokenAddress: string,      // Same as token (legacy)
    registryAddress: string,
    treasuryAddress: string,
    decimals: number,             // Always 18
    totalSupply: string,
    holders: number,
    nonTransferrable: boolean,    // true
    executionDelay: number,       // seconds
    votingDelay: number,          // minutes
    votingDuration: number,       // minutes
    proposalThreshold: string,
    quorum: number,               // percentage
    proposals: [],
    registry: {},
    treasury: {},
    creationDate: Timestamp
}
```

---

## 2. Transferable Token DAO

### Contract
Use factory at Firestore: `contracts/{network}/wrapper_t`

### Deployment Function
```solidity
function deployDAO(DaoParams memory params) public payable

struct DaoParams {
    address[] initialMembers;
    uint256[] initialAmounts;
    string name;
    string symbol;
    string description;
    uint256 executionDelay;
    address admin;
    string[] keys;
    string[] values;
}
```

### JavaScript Example
```javascript
const factory = await ethers.getContractAt('StandardFactoryTransferable', factoryAddress);

await factory.deployDAO({
    initialMembers: ['0xAddress1', '0xAddress2'],
    initialAmounts: [ethers.parseEther('1000'), ethers.parseEther('500')],
    name: 'My Transferable DAO',
    symbol: 'MTDAO',
    description: 'A DAO with transferable tokens',
    executionDelay: 86400,
    admin: deployerAddress,
    keys: [],
    values: []
});
```

### Event Emitted
Same as Non-Transferable: `NewDaoCreated`

### Firestore Structure
Same as Non-Transferable, except:

```javascript
{
    // ... all fields same as above
    nonTransferrable: boolean,    // false (different from non-transferable)
    decimals: number,             // Always 18
}
```

---

## 3. Wrapped ERC20 Token DAO

### Contract
Use factory at Firestore: `contracts/{network}/wrapper_w`

### Deployment Function
```solidity
function deployDAOwithWrappedToken(DaoParamsWrapped memory params) public payable

struct DaoParamsWrapped {
    string name;
    string symbol;
    string description;
    uint256 executionDelay;           // seconds
    address underlyingTokenAddress;
    uint256[] governanceSettings;     // [votingDelay (minutes), votingPeriod (minutes), proposalThreshold, quorumFraction (%)]
    string[] keys;
    string[] values;
    string transferrableStr;          // "true" or "false"
}
```

### JavaScript Example
```javascript
const factory = await ethers.getContractAt('StandardFactoryWrapped', factoryAddress);

await factory.deployDAOwithWrappedToken({
    name: 'USDC Governance DAO',
    symbol: 'GUSD',
    description: 'Wraps USDC for governance',
    executionDelay: 86400,      // 1 day in seconds
    underlyingTokenAddress: '0xUSDCAddress',
    governanceSettings: [
        5,      // votingDelay: 5 minutes
        1440,   // votingPeriod: 1 day (1440 minutes)
        0,      // proposalThreshold: 0 tokens
        4       // quorumFraction: 4%
    ],
    keys: [],
    values: [],
    transferrableStr: 'false'  // Wrapped tokens are non-transferable by default
});
```

### Event Emitted
```solidity
event DaoWrappedDeploymentInfo(
    address indexed daoAddress,
    address indexed wrappedTokenAddress,
    address indexed underlyingTokenAddress,
    address registryAddress,
    string daoName,
    string wrappedTokenSymbol,
    string description,
    uint8 quorumFraction,
    uint256 executionDelay,
    uint48 votingDelay,
    uint32 votingPeriod,
    uint256 proposalThreshold
);
```

### Firestore Structure
Collection: `idaos{Network}`

Document ID: `{daoAddress}`

```javascript
{
    name: string,
    symbol: string,
    description: string,
    address: string,              // DAO contract address
    token: string,                // Wrapped token address
    govTokenAddress: string,      // Same as token (legacy)
    registryAddress: string,
    treasuryAddress: string,
    underlying: string,           // ⭐ Underlying ERC20 token address
    underlyingToken: string,      // ⭐ Same as underlying (for compatibility)
    decimals: number,             // ⭐ Inherited from underlying token (e.g., 6 for USDC)
    totalSupply: string,
    holders: number,
    nonTransferrable: boolean,    // Typically true
    executionDelay: number,       // seconds
    votingDelay: number,          // minutes
    votingDuration: number,       // minutes
    proposalThreshold: string,
    quorum: number,               // percentage
    proposals: [],
    registry: {},
    treasury: {},
    creationDate: Timestamp
}
```

### Key Differences for Wrapped Token DAOs

1. **Two underlying token fields**: Both `underlying` and `underlyingToken` contain the same address
2. **Decimals inheritance**: `decimals` field matches the underlying token's decimals (not hardcoded to 18)
3. **No initial members**: Users must deposit underlying tokens to receive wrapped governance tokens
4. **Token wrapping**: Users interact with the wrapped token contract:
   - `depositFor(address account, uint256 amount)` - Wrap underlying tokens
   - `withdrawTo(address account, uint256 amount)` - Unwrap to get underlying back

---

## Governance Settings

All three types support these governance parameters:

| Parameter | Description | Unit | Typical Values |
|-----------|-------------|------|----------------|
| `executionDelay` | Timelock delay before proposal execution | seconds | 86400 (1 day) |
| `votingDelay` | Delay before voting starts | **minutes** | 5 (5 minutes) |
| `votingPeriod` | Duration of voting period | **minutes** | 10080 (7 days) |
| `proposalThreshold` | Tokens needed to create proposal | wei/tokens | 0 or ethers.parseEther('100') |
| `quorumFraction` | Percentage of supply needed for quorum | percentage | 4 (4%) |

**Important:** All three factory types (non-transferable, transferable, wrapped) use **minutes** for `votingDelay` and `votingPeriod`. These values are multiplied by `1 minutes` internally to convert to seconds for the Governor contract.

---

## Token Operations

### Non-Transferable & Transferable Tokens
- Minted at deployment to initial members
- 18 decimals (standard)
- Requires delegation before voting: `token.delegate(address)`

### Wrapped Tokens
- Zero supply at deployment
- Decimals inherited from underlying token
- Users must deposit underlying tokens: `wrappedToken.depositFor(user, amount)`
- Requires delegation before voting: `wrappedToken.delegate(address)`
- Can unwrap: `wrappedToken.withdrawTo(user, amount)`

---

## Network Configuration

Firestore `networks/{network}` document contains:

```javascript
{
    fromBlock: number,        // Start scanning from this block
    lastSyncedBlock: number,  // Last indexed block
    rpcUrl: string           // RPC endpoint
}
```

---

## Important Notes

1. **Event-Driven Architecture**: The indexer listens for deployment events and automatically populates Firestore
2. **Delegation Required**: All token holders must call `delegate()` before their votes count
3. **Decimals**:
   - Non-transferable & Transferable: Always 18 decimals
   - Wrapped: Inherits from underlying (can be 0-18)
4. **Transferability**:
   - Non-transferable: `nonTransferrable: true`
   - Transferable: `nonTransferrable: false`
   - Wrapped: Typically `nonTransferrable: true` (configurable)
5. **Backward Compatibility**: Both `token` and `govTokenAddress` fields store the governance token address
6. **Wrapped Token Addresses**: Both `underlying` and `underlyingToken` store the underlying ERC20 address

---

## Testing

For testing deployments:

1. Deploy to testnet using factory at `contracts/Etherlink-Testnet/{factoryType}`
2. Check Firestore collection `idaosEtherlink-Testnet` for DAO document
3. Verify all fields are populated correctly
4. Test governance operations (proposals, voting)

---

## Contract ABIs

ABIs are available in the indexer at `indexer/apps/homebase/abis.py`:

- `wrapperAbi` - Non-transferable and transferable factories (StandardFactory)
- `wrapper_w_abi` - Wrapped token factory (StandardFactoryWrapped)
- `daoAbiGlobal` - DAO/Governor contract
- `tokenAbiGlobal` - Governance token contract
