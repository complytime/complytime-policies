# Contributing to ComplyTime Policies

Thank you for your interest in contributing to ComplyTime Policies!

## Contribution Guidelines

This repository follows the [ComplyTime Organization Style Guide](https://github.com/complytime/community/blob/main/STYLE_GUIDE.md). Please review the style guide before submitting contributions.

### Key Principles

- **Single Source of Truth**: Centralize constants and avoid magic strings/numbers
- **Simplicity & Isolation**: Keep functions small and focused
- **Readability**: Code is written for humans first
- **Do Not Reinvent the Wheel**: Leverage existing solutions and contribute upstream

## Contribution Workflow

1. **Fork and Branch**: Create a feature branch from `main`
2. **Make Changes**: Follow the style guide and ensure all validations pass
3. **Validate**: Run `make validate` before committing
4. **Commit**: Follow [Conventional Commits](https://www.conventionalcommits.org/) specification
5. **Pull Request**: Create a PR with a clear description

### Pull Request Requirements

- **Title Format**: `<type>: <description>` (e.g., `feat: add new deployment pattern`)
- **Atomic Changes**: PRs should be small enough to review in one sitting
- **Validation**: All PRs must pass `make validate`
- **Review**: Requires approval from at least two Maintainers

## Validation

Before submitting a PR, ensure all validations pass:

```bash
make validate
```

This validates:
- CALM architectures
- CALM patterns
- CALM standards (JSON Schema)
- Control requirement files
- Architecture against patterns

## Creating Control Requirements

When adding new control requirements, see [tools/README.md](tools/README.md) for guidance on integrating CALM with Gemara policies.

## Questions?

For questions or clarifications, please open an issue or contact the maintainers.
