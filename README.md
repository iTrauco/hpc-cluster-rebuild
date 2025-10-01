# HPC Cluster Rebuild Documentation

## Context

In-home HPC lab cluster experienced catastrophic cascade failure after introducing a new node to the system. The failure manifested across:
- All workstations and compute nodes
- Dual home network infrastructure (Xfinity residential + Comcast Business)
- Display/KVM switching systems
- GPU auto-configuration conflicts

Recovery effort: ~100 hours to reach baseline operational state.

## Cluster Architecture

```
INTERNET
                             │
              ┌──────────────┼──────────────┐
              │              │              │
         Xfinity         Comcast         
       Residential       Business
              │              │
              └──────┬───────┘
                     │
              ═══════╪═══════════════════════════════
              ║  WAN NETWORK (Public Internet)     ║
              ═══════╪═══════════════════════════════
                     │
        ┌────────────┼────────────┬───────────┐
        │            │            │           │
        │            │            │           │
    ┌───▼───┐    ┌──▼────┐   ┌───▼───┐   ┌───▼───┐
    │ T5820 │    │w3-2435│   │w5-2445│   │w5-2445│
    │Master │    │Primary│   │Worker │   │Worker │
    │ Node  │    │Node 1 │   │Node 1 │   │Node 2 │
    │       │    │       │   │       │   │       │
    │(Plan) │    │(Live) │   │(Build)│   │(Off)  │
    └───┬───┘    └───┬───┘   └───┬───┘   └───┬───┘
        │            │           │           │
        │            │           │           │
        └────────────┴───────────┴───────────┘
                     │
              ═══════╪═══════════════════════════════════════
              ║  CONTROL PLANE (Isolated, No Internet)     ║
              ║  • 1Gbps Managed Switches                  ║
              ║  • Static IPs                              ║
              ║  • Orchestration & Inter-node Comm         ║
              ═══════╪═══════════════════════════════════════
                     │
              ┌──────┴──────┐
              │             │
          ┌───▼───┐     ┌───▼───┐
          │  NAS  │     │  UPS  │
          │Storage│     │ Power │
          │(Off)  │     │(Plan) │
          └───────┘     └───────┘

Compute Nodes:
─────────────────────────────────────────────────────────────────
Master (t5820)      │ Dell T5820, Orchestration Only
                    │ Status: ⏳ Offline, Planned
─────────────────────────────────────────────────────────────────
Primary (w32435)    │ Xeon W3-2435, 128GB ECC, RTX A4000 (16GB)
                    │ 2TB NVMe (OS) + 1TB NVMe (Data)
                    │ Status: ✅ Operational (Reference)
─────────────────────────────────────────────────────────────────
Worker 1 (w52445)   │ Xeon W5-2445, 128GB ECC, RTX A5500 (24GB)
                    │ 1TB NVMe
                    │ Status: 🔄 Rebuilding
─────────────────────────────────────────────────────────────────
Worker 2 (w5-2445)  │ Xeon W5-2445, 128GB ECC, RTX A5500 (24GB)
                    │ 1TB NVMe
                    │ Status: ⏳ Offline
─────────────────────────────────────────────────────────────────
```

## Current Status

**Phase 1: System Baseline Restoration (In Progress)**
- ✅ mad-scientist-w32435: Operational and stable (primary node 1, reference system)
- 🔄 mad-scientist-w52445: Clean Ubuntu 24.04.3 install, replicating w32435 config
- ⏳ W5-2445 tower #2: Awaiting rebuild
- ⏳ Dell T5820: Master orchestration node (not yet configured)

## Full Infrastructure Rebuild Scope

This is not just a compute node rebuild - the entire home lab infrastructure is being reconstructed from scratch:

### Infrastructure Components (All Being Rebuilt)
- ✅ **Compute Nodes**: mad-scientist-w32435 operational, mad-scientist-w52445 in progress
- ⏳ **Network Infrastructure**: Home network switches (2x managed 1Gbps) - clean reconfiguration pending
- ⏳ **Storage Layer**: NAS system - offline, will be reintegrated after control plane established
- ⏳ **Power Management**: UPS nodes - being added back one by one with proper documentation
- ⏳ **Display Systems**: KVM switches and multi-monitor configuration - systematic rebuild to prevent refresh rate conflicts
- ⏳ **Orchestration Layer**: Master node (Dell T5820) - awaiting deployment

## Rebuild Philosophy

**One Component at a Time**  
Each infrastructure component is being added back sequentially with full documentation and testing before moving to the next. No shortcuts.

**Document Everything**  
Every configuration, every script, every service gets documented in this repository before deployment.

**No Legacy Cruft**  
Six months of experimental development and configuration drift caused the cascade failure. This rebuild eliminates all legacy baggage.

**Proper Orchestration From Day 1**  
Master node with simple bash/Ansible orchestration replaces ad-hoc manual configuration across nodes.

## Repository Structure

```
/
├── docs/
│   ├── network/              # Network topology and configs
│   ├── display/              # KVM and multi-monitor setup
│   ├── troubleshooting/      # Issues encountered and resolutions
│   └── branching-strategy.md # Git workflow documentation
├── nodes/
│   ├── mad-scientist-w32435/ # Primary node 1 (reference system)
│   │   ├── configs/          # System configurations
│   │   ├── services/         # Service definitions
│   │   └── scripts/          # Node-specific scripts
│   ├── mad-scientist-w52445/ # Worker node 1 (rebuilding)
│   ├── w5-2445-node2/        # Worker node 2 (future)
│   └── t5820-master/         # Orchestration master (future)
├── scripts/
│   ├── system/               # System-level automation
│   ├── monitoring/           # Health checks and monitoring
│   └── deployment/           # Deployment automation
├── services/
│   ├── systemd/              # systemd service definitions
│   └── cron/                 # Cron job definitions
└── config/
    ├── gpu/                  # GPU configuration and lockdown
    ├── display/              # Display/refresh rate configs
    └── shell/                # Shell configs (zsh, vim, etc)
```

## Branching Strategy

### Branch Structure

- **`main`**: Production-ready, stable configurations only. All nodes in working state.
- **`mad-scientist-w32435`**: Reference branch for primary node 1 (baseline configs)
- **`mad-scientist-w52445`**: Active rebuild branch for worker node 1
- **`w5-2445-node2`**: Future rebuild branch for worker node 2
- **`t5820-master`**: Future branch for master orchestrator setup
- **`infrastructure/*`**: Branches for network, display, UPS, NAS integration work

### Workflow

1. **Initial Documentation**: All baseline configs from working system documented in node-specific branch
2. **Replication Work**: Changes/additions happen in target node branch (e.g., `mad-scientist-w52445`)
3. **Testing & Validation**: Node fully operational before merge
4. **Merge to Main**: Only after successful deployment and validation
5. **Tag Releases**: Major milestones tagged (e.g., `v1.0-baseline`, `v2.0-cluster-online`)

### Branch Naming Convention

- Node branches: `<hostname>` (e.g., `mad-scientist-w52445`)
- Infrastructure branches: `infrastructure/<component>` (e.g., `infrastructure/network-switches`)
- Feature branches: `feature/<description>` (e.g., `feature/gdot-camera-service`)
- Hotfix branches: `hotfix/<issue>` (e.g., `hotfix/gpu-refresh-rate`)

### Current Active Branches

- `main`: Production baseline
- `mad-scientist-w52445`: Active rebuild (current work)

## Key Learnings from Failure

- GPU auto-refresh rate detection caused KVM switch failures
- XFCE config overhead contributed to system fragility
- Lack of proper orchestration led to configuration drift
- Manual service management across nodes was unsustainable

## Primary Use Case

**GDOT Camera Stream Archive Service**  
Real-time recording and archival of all Georgia Department of Transportation camera streams for full provenance tracking. This serves both as a public service and as a testbed for AI/ML and large-scale data systems expertise.

## Network Architecture Details

### WAN Layer
- **Purpose**: Public internet connectivity for each compute node
- **Connections**: 
  - Xfinity Residential (backup/redundancy)
  - Comcast Business (primary)
- **Interface**: Built-in 1GbE ethernet ports on each node

### Control Plane Network (Isolated)
- **Purpose**: Cluster management, orchestration, and inter-node communication
- **Topology**: Star topology via managed switches
- **Security**: No internet routing, fully isolated
- **Interface**: USB 1GbE ethernet adapters on each compute node
- **Addressing**: Static IP assignments
- **Traffic Types**:
  - Master → Worker orchestration commands
  - Worker → Master status reporting
  - Inter-worker data transfer
  - NAS storage access
  - Monitoring and health checks

---

**Last Updated**: 2025-09-30  
**Status**: Phase 1 - Baseline System Restoration  
**Active Branch**: `mad-scientist-w52445`