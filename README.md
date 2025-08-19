 Constitution DAO Smart Contract

This repository contains a Clarity smart contract for a basic DAO governance system. The contract enables decentralized proposal creation, voting, and execution, allowing members to collectively manage decisions.

 Features

- **Member Management:**  
  - Add new DAO members (admin only).
- **Proposal System:**  
  - Members can create proposals with descriptions.
  - Voting on proposals (yes/no).
  - Prevents double voting.
  - Proposals can be closed and executed if quorum is met.
- **Quorum Enforcement:**  
  - Proposals require a minimum number of votes to be executed.
- **Error Handling:**  
  - Comprehensive error codes for common failure scenarios.

 Contract Overview

- **Add Member:**  
  Only the admin (`SP000000000000000000002Q6VF78`) can add new members.
- **Create Proposal:**  
  Members can submit proposals with a description (up to 200 ASCII characters).
- **Vote:**  
  Members can vote once per proposal, either in favor or against.
- **Close Proposal:**  
  Proposals can be closed to prevent further voting.
- **Execute Proposal:**  
  Closed proposals with sufficient quorum and more yes votes than no votes can be executed.

## Error Codes

| Code                | Description                      |
|---------------------|----------------------------------|
| `u100`              | Not a DAO member                 |
| `u101`              | Proposal not found               |
| `u102`              | Already voted                    |
| `u103`              | Quorum not met                   |
| `u104`              | Proposal closed                  |
| `u105`              | Proposal still open              |
| `u401`              | Not authorized                   |
| `u500`              | Invalid data                     |
| `u106`              | Proposal did not pass            |

 Usage
 Add Member

```clarity
(add-member '<principal>)
```
 Create Proposal

```clarity
(create-proposal "Proposal description")
```clarity
(vote <proposal-id> true)   ;; Vote yes
(vote <proposal-id> false)  ;; Vote no
 Close Proposal

```clarity
(close-proposal <proposal-id>)
 Execute Proposal

```clarity
(execute-proposal <proposal-id>)
 Deployment

1. Copy the contract file to your Stacks project.
2. Deploy using the Stacks CLI or your preferred deployment tool.


This contract is a template and does not include actual execution logic for proposals. Extend the `execute-proposal` function to add custom execution behavior as needed.
