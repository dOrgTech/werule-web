# DAO Deployment Guide

This guide explains how to deploy the four types of DAOs supported by the Homebase platform and the expected Firestore data structure for each.

## Overview

The platform supports four DAO types:

1. **Non-Transferable Token** - Standard governance tokens that cannot be traded
2. **Transferable Token** - Governance tokens that can be freely transferred
3. **Wrapped ERC20 Token** - Wraps an existing ERC20 token for governance (inherits decimals)
4. **Economy DAO** - Governance with trustless marketplace for project-based work

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

## 4. Economy DAO (Trustless Business)

Economy DAOs extend standard governance with a trustless marketplace for project-based work. They include an Economy contract that manages project creation, funding, and dispute resolution.

### Contract
Use factory at Firestore: `contracts/{network}/wrapper_trustless`

### Deployment Process

Economy DAOs require a **3-step deployment** process:

#### Step 1: Deploy Infrastructure
```solidity
function deployInfrastructure(uint48 timelockDelayInMinutes, uint arbitrationFeeBps) external onlyOwner
```

**Parameters:**
- `timelockDelayInMinutes` - Delay before governance proposals can execute
- `arbitrationFeeBps` - Arbitration fee in basis points (e.g., 500 = 5% of project value)

Deploys:
- Economy contract (initialized with arbitration fee)
- TimelockController
- Registry

**Event Emitted:**
```solidity
event InfrastructureDeployed(address economy, address registry, address timelock);
```

#### Step 2: Deploy DAO and Token
```solidity
function deployDAOToken(
    address registryAddr,
    address timelockAddr,
    TokenParams calldata tokenParams,
    GovParams calldata govParams
) external onlyOwner

struct TokenParams {
    string name;
    string symbol;
    address[] initialMembers;
    uint256[] initialAmounts;
}

struct GovParams {
    string name;
    uint48 timelockDelay;      // blocks
    uint32 votingPeriod;       // blocks
    uint256 proposalThreshold; // wei
    uint8 quorumFraction;      // percentage
}
```

Deploys:
- RepToken (governance token, always non-transferable)
- DAO (Governor contract)

**Event Emitted:**
```solidity
event DAOTokenDeployed(address repToken, address dao);
```

#### Step 3: Configure and Finalize
```solidity
function configureAndFinalize(
    AddressParams calldata addressParams,
    EconomyParams calldata economyParams,
    string[] calldata registryKeys,
    string[] calldata registryValues
) external onlyOwner

struct AddressParams {
    address[2] implAddresses;     // [nativeProjectImpl, erc20ProjectImpl]
    address[5] contractAddresses; // [economy, registry, timelock, repToken, dao]
}

struct EconomyParams {
    uint arbitrationFeeBps;        // Arbitration fee in basis points (must match Step 1)
    uint initialPlatformFeeBps;    // Platform fee in basis points (e.g., 250 = 2.5%)
    uint initialAuthorFeeBps;      // Author fee in basis points (e.g., 500 = 5%)
    uint initialCoolingOffPeriod;  // Seconds before dispute can be raised
    uint initialBackersQuorumBps;  // Quorum for backer votes in basis points
    uint initialProjectThreshold;  // Token threshold for project creation (wei)
    uint initialAppealPeriod;      // Appeal period in seconds
}

// Registry keys/values for initial configuration (e.g., token parities)
// See "Registry Settings" section below for required entries
```

**Events Emitted:**
```solidity
event SuiteConfigured(
    address deployer,
    address indexed economy,
    address registry,
    address timelock,
    address indexed repToken,
    address indexed dao
);

event NewDaoCreated(
    address indexed dao,
    address token,
    address[] initialMembers,
    uint256[] initialAmounts,
    string name,
    string symbol,
    string description,      // Always "Economy DAO"
    uint256 executionDelay,
    address registry,
    string[] keys,
    string[] values
);
```

### JavaScript Example
```javascript
const { ethers } = require("hardhat");

const TrustlessFactory = await ethers.getContractFactory("TrustlessFactory");
const factory = TrustlessFactory.attach(factoryAddress);

// Step 1: Deploy Infrastructure
const arbitrationFeeBps = 500; // 5% arbitration fee
const tx1 = await factory.deployInfrastructure(2, arbitrationFeeBps); // 2 minutes timelock delay
const receipt1 = await tx1.wait();
// Parse InfrastructureDeployed event to get economyAddr, registryAddr, timelockAddr

// Step 2: Deploy DAO and Token
const tokenParams = {
    name: "My Economy DAO Token",
    symbol: "MEDT",
    initialMembers: [member1, member2],
    initialAmounts: [ethers.parseEther("100"), ethers.parseEther("50")]
};

const govParams = {
    name: "My Economy DAO Governor",
    timelockDelay: 1,                          // 1 block
    votingPeriod: 50400,                       // ~1 week in blocks
    proposalThreshold: ethers.parseEther("10"),
    quorumFraction: 4                          // 4%
};

const tx2 = await factory.deployDAOToken(registryAddr, timelockAddr, tokenParams, govParams);
const receipt2 = await tx2.wait();
// Parse DAOTokenDeployed event to get repTokenAddr, daoAddr

// Step 3: Configure and Finalize
const addressParams = {
    implAddresses: [nativeProjectImpl, erc20ProjectImpl],
    contractAddresses: [economyAddr, registryAddr, timelockAddr, repTokenAddr, daoAddr]
};

const economyParams = {
    arbitrationFeeBps: arbitrationFeeBps,    // Must match Step 1 value
    initialPlatformFeeBps: 250,              // 2.5%
    initialAuthorFeeBps: 500,                // 5%
    initialCoolingOffPeriod: 259200,         // 3 days in seconds
    initialBackersQuorumBps: 5100,           // 51%
    initialProjectThreshold: ethers.parseEther("10"),
    initialAppealPeriod: 604800              // 7 days in seconds
};

// Initial registry entries for token parity (required for reputation calculation)
const NATIVE_CURRENCY = "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee";
const registryKeys = [
    `jurisdiction.parity.${NATIVE_CURRENCY}`,  // Native currency parity
    "benefits.claim.gracePeriod"               // Grace period for claiming benefits
];
const registryValues = [
    "1000000000000000000",  // 1e18 = 1:1 parity (1 XTZ = 1 reputation)
    "2592000"              // 30 days in seconds
];

const tx3 = await factory.configureAndFinalize(
    addressParams,
    economyParams,
    registryKeys,
    registryValues
);
await tx3.wait();
```

### Firestore Structure
Collection: `idaos{Network}`

Document ID: `{daoAddress}`

```javascript
{
    name: string,
    symbol: string,
    description: string,          // "Economy DAO"
    address: string,              // DAO contract address
    token: string,                // RepToken address
    registryAddress: string,
    treasuryAddress: string,
    economy: string,              // ⭐ Economy contract address (unique to Economy DAOs)
    decimals: number,             // Always 18
    totalSupply: string,
    holders: number,
    nonTransferrable: boolean,    // Always true (economy tokens are non-transferable)
    executionDelay: number,       // seconds
    votingDelay: number,          // blocks
    votingDuration: number,       // blocks
    proposalThreshold: string,
    quorum: number,               // percentage
    proposals: [],
    registry: {},
    treasury: {},
    creationDate: Timestamp
}
```

### Key Differences for Economy DAOs

1. **Economy field**: The `economy` field contains the Economy contract address (null for standard DAOs)
2. **3-step deployment**: Unlike standard DAOs (single transaction), Economy DAOs require 3 separate transactions
3. **Always non-transferable**: Economy DAO tokens are always non-transferable
4. **Project implementations**: Requires NativeProject and ERC20Project implementation addresses for the clone factory
5. **Economy parameters**: Configurable fees, cooling-off periods, quorums, and thresholds for the trustless marketplace

### Economy Contract Features

The Economy contract (`economy` address) provides:

- **Project Creation**: `createProject()` / `createERC20Project()` - Creates new projects using clone pattern
- **Platform Configuration**: Fees, cooling-off periods, appeal periods (governance-controlled)
- **Reputation Gating**: Project creation requires minimum token holdings (`projectThreshold`)

### Arbitration Fee Model

The arbitration fee is a **percentage-based fee** calculated from the project value at signing time:

- **Fee Calculation**: `arbitrationFee = (projectValue * arbitrationFeeBps) / 10000`
- **Contractor Stakes Half**: When signing, the contractor stakes half the calculated fee
- **Contributors Fund Half**: If a dispute occurs, the other half comes from project funds
- **Arbiter Gets Paid Regardless**: The arbiter receives the full fee regardless of the ruling outcome (prevents perverse incentives)
- **No Dispute = Stake Returned**: If the project closes without dispute, the contractor can reclaim their stake

**Example:** For a 5% fee (`arbitrationFeeBps = 500`) on a 100 ETH project:
- Total arbitration fee: 5 ETH
- Contractor stakes: 2.5 ETH when signing
- If dispute: Arbiter gets 5 ETH (2.5 from contractor stake + 2.5 from project funds)
- If no dispute: Contractor reclaims 2.5 ETH stake

### Project Implementation Contracts

The NativeProject and ERC20Project implementation addresses are passed to `configureAndFinalize()` during deployment. These are clone templates - each new project is a minimal proxy pointing to these implementations.

Implementation addresses for each network are stored in the deployment output files (e.g., `deployments/etherlink-testnet-economy-redeploy.json`).

### Registry Settings

Economy DAOs use Registry entries to configure token parities (for reputation calculation) and other parameters. These are set during deployment via the `registryKeys` and `registryValues` parameters.

#### Required Registry Entries

| Key | Value Format | Description |
|-----|--------------|-------------|
| `jurisdiction.parity.{tokenAddress}` | uint as string (18 decimals) | Reputation multiplier for token earnings/spendings |
| `benefits.claim.gracePeriod` | uint as string (seconds) | Grace period before unclaimed epoch rewards can be reclaimed |

#### Token Parity Format

The parity key format is: `jurisdiction.parity.` + lowercase hex address

**Special address for native currency:** `0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee`

**Value examples:**
- `"1000000000000000000"` = 1:1 parity (1 token = 1 reputation)
- `"2000000000000000000"` = 2:1 parity (1 token = 2 reputation)
- `"500000000000000000"` = 0.5:1 parity (1 token = 0.5 reputation)

#### Example: Adding ERC20 Token Parity

To add USDC support with 1:1 parity:
```javascript
const registryKeys = [
    "jurisdiction.parity.0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee",  // Native
    "jurisdiction.parity.0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48",  // USDC
    "benefits.claim.gracePeriod"
];
const registryValues = [
    "1000000000000000000",           // 1:1 for native
    "1000000000000000000000000000000", // Adjusted for USDC (6 decimals)
    "2592000"                        // 30 days
];
```

**Note:** Token parities can be modified after deployment through DAO governance proposals calling `registry.editRegistry()` or `registry.batchEditRegistry()`.

---

## Contract ABIs

ABIs are available in the indexer at `indexer/apps/homebase/abis.py`:

- `wrapperAbi` - Non-transferable and transferable factories (StandardFactory)
- `wrapper_w_abi` - Wrapped token factory (StandardFactoryWrapped)
- `trustless_wrapper_abi` - Economy DAO factory (TrustlessFactory)
- `daoAbiGlobal` - DAO/Governor contract
- `tokenAbiGlobal` - Governance token contract
