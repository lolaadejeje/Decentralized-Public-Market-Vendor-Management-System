# Decentralized Public Market Vendor Management System

A comprehensive blockchain-based system for managing public market vendors, built on the Stacks blockchain using Clarity smart contracts.

## Overview

This system provides a decentralized solution for managing public market operations including vendor stall assignments, fee collection, health permit verification, product certification, and customer feedback management.

## System Components

### 1. Stall Assignment Contract (`stall-assignment.clar`)
- Manages vendor stall allocations
- Handles waiting lists for popular market areas
- Tracks stall availability and assignments
- Supports stall transfers and releases

### 2. Fee Collection Contract (`fee-collection.clar`)
- Processes vendor payments (daily, weekly, monthly)
- Tracks payment history and outstanding balances
- Manages different fee structures by stall type
- Handles late payment penalties

### 3. Health Permit Verification Contract (`health-permit.clar`)
- Verifies and tracks health permits for food vendors
- Manages permit expiration dates
- Handles permit renewals and suspensions
- Maintains compliance records

### 4. Product Certification Contract (`product-certification.clar`)
- Validates organic and local produce claims
- Manages certification authorities
- Tracks product authenticity and origin
- Handles certification disputes

### 5. Customer Feedback Contract (`customer-feedback.clar`)
- Collects and manages vendor ratings
- Handles customer complaints and resolutions
- Tracks vendor reputation scores
- Manages feedback moderation

## Key Features

- **Decentralized Governance**: No single point of control
- **Transparent Operations**: All transactions recorded on blockchain
- **Automated Compliance**: Smart contract enforcement of rules
- **Vendor Accountability**: Reputation-based system
- **Customer Protection**: Dispute resolution mechanisms

## Data Structures

### Vendor Profile
- Principal address
- Registration date
- Stall assignments
- Payment history
- Compliance status
- Reputation score

### Stall Information
- Unique stall ID
- Location details
- Size and type
- Current occupant
- Fee structure
- Availability status

### Payment Records
- Payment amount and date
- Fee type (daily/weekly/monthly)
- Payment status
- Late fees applied

### Permits and Certifications
- Permit/certification type
- Issue and expiration dates
- Issuing authority
- Verification status

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Node.js and npm
- Stacks wallet for testing

### Installation

1. Clone the repository
2. Install dependencies:
   \`\`\`bash
   npm install
   \`\`\`

3. Run tests:
   \`\`\`bash
   npm test
   \`\`\`

4. Deploy contracts:
   \`\`\`bash
   clarinet deploy
   \`\`\`

## Testing

The system includes comprehensive tests using Vitest:
- Unit tests for each contract function
- Integration tests for cross-contract workflows
- Edge case and error condition testing

## Contract Interactions

### For Vendors
1. Register as a vendor
2. Apply for stall assignment
3. Make fee payments
4. Submit health permits
5. Register product certifications

### For Customers
1. Submit vendor ratings
2. File complaints
3. View vendor information
4. Check product certifications

### For Market Administrators
1. Manage stall availability
2. Process permit verifications
3. Handle dispute resolutions
4. Monitor system health

## Security Considerations

- All functions include proper access controls
- Input validation prevents malicious data
- State changes are atomic and consistent
- Emergency pause mechanisms included

## Future Enhancements

- Multi-market support
- Advanced analytics dashboard
- Mobile application integration
- IoT sensor integration for real-time monitoring

## License

MIT License - see LICENSE file for details
