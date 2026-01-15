# ComplyTime Policies

This repository contains CALM (Common Architecture Language Model) architectures, standards, and controls for the ComplyTime ecosystem.

## Overview

This repository demonstrates the integration of CALM architectures with Gemara compliance policies. It provides:

- **CALM Architecture**: Example architecture showing ComplyTime deployment patterns
- **CALM Patterns**: Deployment patterns that validate required components and control references
- **CALM Standards**: Custom standards for node metadata, relationship metadata, and Gemara policy inclusion
- **Control Requirements**: Gemara assessment requirements mapped to CALM control requirements

### What This Demonstrates

This implementation showcases several CALM features:

1. **Custom Standards**: Extends CALM core schemas with ComplyTime-specific metadata requirements
2. **Pattern Validation**: Uses JSON Schema patterns to enforce deployment requirements
3. **Control Integration**: Links CALM architectures to Gemara compliance policies via control requirements
4. **URL Mapping**: Demonstrates how to map custom `gemara://` URLs to local control requirement files

## Quick Start

### Prerequisites

- [CALM CLI](https://github.com/finos/calm-cli) installed: `npm install -g @finos/calm-cli`
- Python 3 (for control file validation)

### View Available Commands

```bash
# List all commands available from Makefile
make help
```

### Validate Architecture Against Pattern

```bash
# Validate example architecture against deployment pattern
make validate-example
```

### Validate Everything

```bash
# Run all validations (architectures, patterns, standards, controls)
make validate
```

### Generate Documentation

```bash
# Generate visual documentation website from CALM architecture
make docify
```

## Repository Structure

```
.
├── architecture/          # CALM architecture files
│   └── complytime-example.arch.json
├── patterns/              # CALM pattern files (JSON Schema)
│   └── complytime-deployment.pattern.json
├── standards/             # Custom CALM standards (JSON Schema)
│   ├── complytime-node-metadata.standard.json
│   ├── complytime-relationship-metadata.standard.json
│   ├── complytime-gemara-policy-inclusion.standard.json
│   └── url-mapping.json   # Maps gemara:// URLs to local files
├── controls/              # Control requirement files
│   ├── ccc-core-cn01-tr01.requirement.json
│   └── cloud-policy-001-cn01-tr01.requirement.json
└── tools/                 # Utility scripts and documentation
    ├── README.md           # Guide for integrating CALM with Gemara
    ├── validate-control-files.py
    └── gemara-resolve-example.py
```

## Integrating CALM with Gemara

This repository demonstrates how to integrate CALM architectures with Gemara compliance policies through:

1. **Creating Standards**: Define CALM standards that enforce metadata requirements needed to work with Gemara policies
2. **Creating Patterns from Policies**: Generate CALM patterns from Gemara Layer 3 Policy documents that validate architectures against compliance requirements

See [tools/README.md](tools/README.md) for detailed guidance on integrating CALM with Gemara policies.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on contributing to this repository.

## License

See [LICENSE](LICENSE) file for details.
