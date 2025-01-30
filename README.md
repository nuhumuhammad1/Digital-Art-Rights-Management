# ArtChain: Blockchain-Based Digital Art Rights Management

ArtChain is a decentralized platform that enables artists, collectors, and galleries to manage digital art ownership, licensing, and royalties through blockchain technology and smart contracts.

## Features

### Digital Art Registration
- Secure artwork registration on the blockchain with permanent timestamping
- Metadata storage including artwork details, creation date, and ownership history
- Support for multiple file formats (images, videos, 3D models, etc.)
- Optional private key encryption for sensitive artwork data

### Smart Contract Management
- Automated smart contracts for artwork registration and transfer
- Fractional ownership capabilities with customizable share distributions
- Configurable licensing terms and usage rights
- Real-time royalty distribution to all stakeholders

### NFT Integration
- ERC-721 and ERC-1155 standard compliance
- Unique tokens representing individual artworks or collections
- Built-in support for limited editions and series
- Embedded licensing terms within token metadata

### Marketplace Features
- Direct integration with major NFT marketplaces
- Real-time price discovery and artwork valuation
- Automated royalty tracking across secondary sales
- Support for multiple payment methods and cryptocurrencies

## Technical Architecture

### Backend Components
- Ethereum blockchain for smart contract deployment
- IPFS for decentralized artwork storage
- Node.js API server for platform interactions
- PostgreSQL database for off-chain data

### Smart Contracts
```solidity
// Core contract interfaces
interface IArtworkRegistry {
    function registerArtwork(bytes32 artworkHash, string metadata) external;
    function transferOwnership(uint256 tokenId, address newOwner) external;
    function updateLicenseTerms(uint256 tokenId, bytes32 terms) external;
}

interface IRoyaltyManager {
    function setRoyaltyTerms(uint256 tokenId, address[] recipients, uint256[] shares) external;
    function distributeRoyalties(uint256 tokenId) external payable;
}
```

### API Endpoints
- `POST /api/v1/artworks`: Register new artwork
- `GET /api/v1/artworks/{id}`: Retrieve artwork details
- `PUT /api/v1/artworks/{id}/license`: Update licensing terms
- `POST /api/v1/royalties/distribute`: Trigger royalty distribution

## Getting Started

### Prerequisites
- Node.js v16 or higher
- PostgreSQL 13+
- MetaMask or compatible Web3 wallet
- Ethereum network access (mainnet or testnet)

### Installation
1. Clone the repository:
```bash
git clone https://github.com/your-org/artchain.git
cd artchain
```

2. Install dependencies:
```bash
npm install
```

3. Configure environment variables:
```bash
cp .env.example .env
# Edit .env with your configuration
```

4. Initialize the database:
```bash
npm run db:migrate
```

5. Start the development server:
```bash
npm run dev
```

### Configuration
Create a `.env` file with the following variables:
```
ETHEREUM_NETWORK=mainnet
IPFS_NODE_URL=your-ipfs-node
DATABASE_URL=postgresql://user:password@localhost:5432/artchain
JWT_SECRET=your-secret-key
```

## Usage Examples

### Registering Artwork
```javascript
const artchain = new ArtChain(config);

// Register new artwork
const artwork = await artchain.registerArtwork({
    title: "Digital Masterpiece",
    artist: "0x123...",
    file: artworkFile,
    license: {
        type: "exclusive",
        duration: "perpetual",
        territories: ["global"]
    }
});
```

### Setting Up Royalties
```javascript
// Configure royalty distribution
await artchain.setRoyalties(artwork.id, [
    { address: "0x123...", share: 70 }, // Artist
    { address: "0x456...", share: 30 }  // Gallery
]);
```

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details on:
- Code of Conduct
- Development workflow
- Testing requirements
- Pull request process

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Security

For security concerns, please email security@artchain.io or submit a detailed report through our bug bounty program.

## Support

- Documentation: [docs.artchain.io](https://docs.artchain.io)
- Discord: [ArtChain Community](https://discord.gg/artchain)
- Email: support@artchain.io
