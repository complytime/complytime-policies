# SPDX-License-Identifier: Apache-2.0

.PHONY: test test-bundle-parsing lint

test: test-bundle-parsing

test-bundle-parsing:
	@./scripts/test-bundle-parsing.sh

lint:
	@echo "TODO: wire yamllint"
