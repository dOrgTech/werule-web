# Proposal Description Format

When submitting proposals to the Governor contract, the description string must follow a specific format for the web app and indexer to correctly parse the proposal type and metadata.

## Format

```
{title}0|||0{type}0|||0{description}0|||0{link}
```

**Separator:** `0|||0`

## Components

1. **Title** - Proposal title (required)
2. **Type** - Proposal type identifier (required)
3. **Description** - Full proposal description (required)
4. **Link** - External link for more info (optional, can be empty string)

## Valid Type Values

| Type | Description |
|------|-------------|
| `registry` | Update registry key/value pair |
| `transfer` | Transfer tokens from treasury |
| `mint` | Mint new governance tokens |
| `burn` | Burn governance tokens |
| `quorum` | Update quorum percentage |
| `voting_delay` | Update voting delay period |
| `voting_period` | Update voting duration |
| `threshold` | Update proposal threshold |
| `contract_call` | Arbitrary contract call |
| `batch` | Multiple actions in one proposal |

## Examples

### Registry Update
```
Update DAO Website0|||0registry0|||0This proposal updates the dao.website registry entry to point to our new domain.0|||0https://forum.example.com/proposal/123
```

### Token Transfer
```
Fund Development Team0|||0transfer0|||0Transfer 10,000 tokens to the development team wallet for Q1 deliverables.0|||0
```

### Batch Proposal
```
Q1 Funding Round0|||0batch0|||0Multiple transfers for various team members and expenses.0|||0https://docs.example.com/q1-budget
```

## Notes

- All four components must be present (link can be empty)
- The separator `0|||0` must be used exactly as shown
- Type must match one of the valid values (case-sensitive)
- For proposals with multiple actions, use type `batch`
