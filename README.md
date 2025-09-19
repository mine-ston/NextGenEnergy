# NextGenEnergy

NextGenEnergy is a synthetic assets smart contract system for tracking fusion power and revolutionary energy technology development on the Stacks blockchain. The contract enables the creation, management, and trading of synthetic assets representing various energy technologies while tracking development milestones and performance metrics.

## Features

### Core Asset Management
- **Synthetic Energy Assets**: Create and manage tokenized representations of energy technologies
- **Multi-Technology Support**: Support for fusion power, advanced solar, next-gen wind, enhanced geothermal, and hydrogen fuel technologies
- **Performance Tracking**: Real-time performance indexing and value updates
- **Asset Transfers**: Secure transfer of asset shares between users

### Development Milestone System
- **Milestone Creation**: Define development targets with impact multipliers
- **Progress Tracking**: Monitor completion status and achievement dates
- **Performance Impact**: Automatic asset performance updates upon milestone completion
- **Target Date Management**: Time-based milestone tracking

### Fusion Power Metrics
- **Plasma Temperature Monitoring**: Track fusion reactor plasma temperatures
- **Energy Gain Factor**: Monitor energy output versus input ratios
- **Uptime Percentage**: Track operational reliability metrics
- **Real-time Updates**: Continuous metric updates with blockchain timestamps

### Investment Tracking
- **Investment Recording**: Track user investments and share ownership
- **Balance Management**: Maintain user asset balances across multiple technologies
- **Investment History**: Historical investment data with timestamps

### Security & Administration
- **Multi-level Authorization**: Contract owner and authorized manager system
- **Emergency Controls**: Contract pause functionality for security
- **Access Management**: Granular permission control for operations

## Technical Specifications

- **Blockchain**: Stacks
- **Language**: Clarity v2
- **Epoch**: 2.5
- **Testing Framework**: Vitest with Clarinet SDK
- **Contract Version**: 1.0.0

### Supported Energy Technologies

| Technology | ID | Description |
|------------|----|-----------  |
| Fusion Power | 1 | Nuclear fusion energy systems |
| Advanced Solar | 2 | Next-generation photovoltaic technology |
| Next-Gen Wind | 3 | Advanced wind energy systems |
| Enhanced Geothermal | 4 | Improved geothermal energy extraction |
| Hydrogen Fuel | 5 | Hydrogen-based energy systems |

## Installation

### Prerequisites

- Node.js (v16 or higher)
- Clarinet CLI
- Stacks CLI (optional, for deployment)

### Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd NextGenEnergy
```

2. Navigate to the contract directory:
```bash
cd NextGenEnergy_contract
```

3. Install dependencies:
```bash
npm install
```

4. Run tests:
```bash
npm test
```

5. Run tests with coverage and cost analysis:
```bash
npm run test:report
```

## Usage Examples

### Creating an Energy Asset

```clarity
;; Create a fusion power asset
(contract-call? .NextGenEnergy create-energy-asset
  "Fusion Reactor Alpha"
  u1  ;; FUSION-POWER
  u1000000  ;; 1M initial supply
  u100      ;; Initial value per unit
)
```

### Creating a Development Milestone

```clarity
;; Create a milestone for achieving 100M degree plasma
(contract-call? .NextGenEnergy create-milestone
  u1  ;; asset-id
  "100M Degree Plasma"
  "Achieve sustained plasma temperature of 100 million degrees"
  u2024  ;; target block height
  u25    ;; 25% performance boost
)
```

### Updating Fusion Metrics

```clarity
;; Update fusion reactor performance metrics
(contract-call? .NextGenEnergy update-fusion-metrics
  u1         ;; asset-id
  u150000000 ;; plasma temperature (150M degrees)
  u110       ;; energy gain factor (110%)
  u95        ;; uptime percentage (95%)
)
```

### Investing in an Asset

```clarity
;; Invest 1000 units in fusion power asset
(contract-call? .NextGenEnergy invest-in-asset
  u1    ;; asset-id
  u1000 ;; investment amount
)
```

### Transferring Asset Shares

```clarity
;; Transfer 100 shares to another user
(contract-call? .NextGenEnergy transfer-asset-shares
  u1    ;; asset-id
  u100  ;; amount
  'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7 ;; recipient
)
```

## Contract Functions Documentation

### Public Functions

#### Asset Management

- **`create-energy-asset`**: Create a new synthetic energy asset
  - Parameters: name, technology-type, initial-supply, initial-value
  - Returns: asset-id
  - Authorization: Authorized managers only

- **`update-asset-performance`**: Update asset performance metrics
  - Parameters: asset-id, new-performance-index, new-value
  - Authorization: Authorized managers only

- **`transfer-asset-shares`**: Transfer asset shares between users
  - Parameters: asset-id, amount, recipient
  - Authorization: Any user with sufficient balance

#### Milestone Management

- **`create-milestone`**: Create a development milestone
  - Parameters: asset-id, milestone-name, description, target-date, impact-multiplier
  - Authorization: Authorized managers only

- **`complete-milestone`**: Mark a milestone as completed
  - Parameters: milestone-id
  - Authorization: Authorized managers only

#### Fusion Power Metrics

- **`update-fusion-metrics`**: Update fusion-specific performance data
  - Parameters: asset-id, plasma-temperature, energy-gain-factor, uptime-percentage
  - Authorization: Authorized managers only

#### Investment Functions

- **`invest-in-asset`**: Record investment in an energy asset
  - Parameters: asset-id, amount
  - Authorization: Any user

#### Administrative Functions

- **`add-manager`**: Add authorized manager
  - Parameters: manager principal
  - Authorization: Contract owner only

- **`remove-manager`**: Remove authorized manager
  - Parameters: manager principal
  - Authorization: Contract owner only

- **`toggle-contract-status`**: Emergency pause/unpause contract
  - Authorization: Contract owner only

### Read-Only Functions

- **`get-asset-info`**: Retrieve asset information
- **`get-user-balance`**: Get user's balance for specific asset
- **`get-milestone-info`**: Retrieve milestone details
- **`get-fusion-metrics`**: Get fusion power metrics
- **`get-investment-info`**: Get investment details
- **`get-total-assets-value`**: Get total contract value
- **`is-manager`**: Check if user is authorized manager
- **`get-contract-status`**: Check if contract is active
- **`get-next-asset-id`**: Get next available asset ID
- **`get-next-milestone-id`**: Get next available milestone ID

## Deployment Guide

### Testnet Deployment

1. Configure Clarinet for testnet:
```bash
clarinet integrate
```

2. Deploy to testnet:
```bash
clarinet deployments generate --testnet
clarinet deployments apply --testnet
```

### Mainnet Deployment

1. Configure mainnet settings in `settings/Mainnet.toml`

2. Generate deployment plan:
```bash
clarinet deployments generate --mainnet
```

3. Review and apply deployment:
```bash
clarinet deployments apply --mainnet
```

## Development

### Running Tests

```bash
# Run all tests
npm test

# Run tests with coverage and cost analysis
npm run test:report

# Watch mode for development
npm run test:watch
```

### Project Structure

```
NextGenEnergy_contract/
├── contracts/
│   └── NextGenEnergy.clar      # Main contract
├── tests/
│   └── NextGenEnergy.test.ts   # Test suite
├── settings/
│   ├── Devnet.toml            # Development configuration
│   ├── Testnet.toml           # Testnet configuration
│   └── Mainnet.toml           # Mainnet configuration
├── Clarinet.toml              # Project configuration
├── package.json               # Node.js dependencies
└── vitest.config.js           # Test configuration
```

## Security Notes

### Access Control
- Contract functions are protected by multi-level authorization
- Only contract owner can manage authorized managers
- Critical functions require manager authorization
- Emergency pause functionality available to contract owner

### Error Handling
The contract implements comprehensive error handling with specific error codes:
- `ERR-NOT-AUTHORIZED (401)`: Insufficient permissions
- `ERR-INVALID-AMOUNT (402)`: Invalid amount parameters
- `ERR-INSUFFICIENT-BALANCE (403)`: Insufficient user balance
- `ERR-ASSET-NOT-FOUND (404)`: Asset does not exist
- `ERR-MILESTONE-EXISTS (409)`: Milestone already completed

### Best Practices
- Always verify asset existence before operations
- Validate user balances before transfers
- Check authorization before sensitive operations
- Monitor contract status before execution
- Use appropriate impact multipliers for milestones

### Recommendations
- Implement proper key management for authorized managers
- Monitor fusion metrics for anomalies
- Regular audits of asset performance updates
- Backup critical contract state data
- Implement additional validation for extreme metric values

## License

This project is licensed under the ISC License.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Implement changes with appropriate tests
4. Submit a pull request with detailed description

## Support

For questions, issues, or contributions, please refer to the project repository or contact the development team.