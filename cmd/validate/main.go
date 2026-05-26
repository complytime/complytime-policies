// SPDX-License-Identifier: Apache-2.0

// Command gemara-validate loads all Gemara governance YAML files through the
// go-gemara SDK (validate + normalize) and re-emits them as normalized YAML.
// Modeled after grc's validateRoot in gemara-registry-cli.
package main

import (
	"context"
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/gemaraproj/go-gemara"
	"github.com/gemaraproj/go-gemara/fetcher"
	goyaml "github.com/goccy/go-yaml"
)

func main() {
	governanceDir := flag.String("governance-dir", "governance", "Root directory containing Gemara YAML files")
	outputDir := flag.String("output-dir", "generated", "Output directory for normalized YAML")
	flag.Parse()

	ctx := context.Background()

	files, err := findYAMLFiles(*governanceDir)
	if err != nil {
		fmt.Fprintf(os.Stderr, "find yaml files: %v\n", err)
		os.Exit(1)
	}

	if len(files) == 0 {
		fmt.Fprintf(os.Stderr, "no YAML files found in %s\n", *governanceDir)
		os.Exit(1)
	}

	var errors int
	var processed int

	for _, path := range files {
		relPath, err := filepath.Rel(*governanceDir, path)
		if err != nil {
			relPath = path
		}

		normalized, typeName, err := loadAndMarshal(ctx, path)
		if err != nil {
			fmt.Fprintf(os.Stderr, "FAIL %s: %v\n", path, err)
			errors++
			continue
		}

		outPath := filepath.Join(*outputDir, relPath)
		if err := writeFile(outPath, normalized); err != nil {
			fmt.Fprintf(os.Stderr, "FAIL write %s: %v\n", outPath, err)
			errors++
			continue
		}

		fmt.Printf("OK   %-16s %s -> %s\n", typeName, path, outPath)
		processed++
	}

	fmt.Printf("\n%d file(s) processed, %d error(s)\n", processed, errors)
	if errors > 0 {
		os.Exit(1)
	}
}

func findYAMLFiles(root string) ([]string, error) {
	var files []string
	err := filepath.Walk(root, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if !info.IsDir() && (strings.HasSuffix(path, ".yaml") || strings.HasSuffix(path, ".yml")) {
			files = append(files, path)
		}
		return nil
	})
	return files, err
}

// loadAndMarshal reads a Gemara YAML file, detects its type, loads it through
// the go-gemara SDK (which validates the structure), and re-marshals the typed
// struct back to YAML. Returns the normalized YAML bytes and the detected type name.
func loadAndMarshal(ctx context.Context, filePath string) ([]byte, string, error) {
	data, err := os.ReadFile(filePath)
	if err != nil {
		return nil, "", fmt.Errorf("read: %w", err)
	}

	t, err := gemara.DetectType(data)
	if err != nil {
		return nil, "", fmt.Errorf("detect type: %w", err)
	}

	f := &fetcher.File{}
	var out any
	var typeName string

	switch t {
	case gemara.PolicyArtifact:
		typeName = "Policy"
		out, err = gemara.Load[gemara.Policy](ctx, f, filePath)
	case gemara.GuidanceCatalogArtifact:
		typeName = "GuidanceCatalog"
		out, err = gemara.Load[gemara.GuidanceCatalog](ctx, f, filePath)
	default:
		typeName = "ControlCatalog"
		out, err = gemara.Load[gemara.ControlCatalog](ctx, f, filePath)
	}
	if err != nil {
		return nil, typeName, fmt.Errorf("load %s: %w", typeName, err)
	}

	normalized, err := goyaml.Marshal(out)
	if err != nil {
		return nil, typeName, fmt.Errorf("marshal %s: %w", typeName, err)
	}

	return normalized, typeName, nil
}

func writeFile(path string, data []byte) error {
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		return err
	}
	return os.WriteFile(path, data, 0o644)
}
