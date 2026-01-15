# AGENTS.md

Agent-specific instructions for ComplyTime codebases.

---

## Quick Reference

**Critical Rules:**
- Use latest stable versions, pin when possible (no alpha/beta/rc)
- Centralize constants (no magic strings/numbers)
- Ask design questions BEFORE implementing features
- Ask lifecycle/retention questions BEFORE creating data storage
- Suggest production best practices for cloud resources

---

## Dependency Management

- Use latest stable versions (no alpha/beta/rc)
- Pin exact versions when possible (prefer `1.2.3` over `^1.2.3`)
- Use semantic versioning ranges (`^` or `~`) only when pinning is impractical
- When suggesting dependencies, evaluate: adoption rate, governance model, maintenance frequency, community health

---

## Code Style

**General:**
- Empty line at end of file (POSIX standard)
- Line length: 99 characters max (exceptions for readability)
- Write tests with descriptive names and edge cases
- Run tests locally before committing
- Fix all test and type errors before PR

**Go:**
- File names: lowercase with underscores (`my_file.go`)
- Package names: short, lowercase, no underscores
- Always check and return errors
- Format with `goimports` and `go fmt`
- License header: `// SPDX-License-Identifier: Apache-2.0`
- Run `.golangci.yml` checks locally before PR
- Place shared constants in `internal/consts/consts.go` or `consts.go`

**Python:**
- Use type hints
- Format with `black` and `isort`
- Lint with `ruff`
- Type check with `mypy`
- License header: `# SPDX-License-Identifier: Apache-2.0`
- Place shared constants in `settings.py` or `constants.py` (use `UPPER_CASE` for constant names)
- Non-Python files: use [Megalinter](https://github.com/oxsecurity/megalinter)

---

## Required Questions Before Implementation

**Before Implementing Features:**
1. Ask: "Who is the specific User Persona for this feature?"
2. Ask: "What is the primary problem this solves for them?"
3. Ask: "Would you like to see a mock-up or non-functional prototype first?"
4. Do NOT output full implementation code until design intent is confirmed

**Before Creating Data Storage:**
1. Ask: "What is the retention policy for this data? (When do we delete it?)"
2. Ask: "Are there compliance requirements regarding immutability or encryption?"
3. Include default resource lifecycle policies in generated code

**Cloud Resources:**
- Do NOT provide minimal resources only
- ALWAYS append comment section listing "Production Best Practices" (e.g., Object Lock for S3, encryption at rest, public access blocking)
- Ask user if they want to enable these features

---

## Variable Names

- No magic strings/numbers inline
- Use descriptive variable names (e.g., `days_until_expiration` not `d`)

---

## PR Workflow

**Branching:**
- Create feature branches from `main`
- Keep PRs focused on a single change or feature

**PR Requirements:**
- Title format: `<type>: <description>` (e.g., `feat: implement oscal validation logic`)
- Requires review from at least two Maintainers
- Must pass CI/CD checks (linting, testing, build)
- Exceptions: maintainers can discuss exceptions for external/transient failures

**Commits:**
- Follow [Conventional Commits](https://www.conventionalcommits.org/)
- Format: `<type>(<scope>): <description>`
- Include DCO sign-off: use `git commit --signoff` or add `Signed-off-by: Your Name <email@example.com>`

---

## Design Documentation

- Document design decisions in available location (check for `adr/`, `docs/design/`, or similar directories)
- If no standard location exists, use inline comments with clear references
- Include rationale, alternatives considered, and trade-offs

---

## Incremental Improvement

When working on a bug/feature:
- If you identify improvements (refactoring, formatting, naming), consider opening a **separate PR or Issue**
- Keep aesthetic changes separate from logic fixes

---

The ComplyTime community repository containing more detailed guides is located at: https://github.com/complytime/community
