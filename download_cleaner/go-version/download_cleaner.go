package main

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

func main() {
	// If there is a directory passed as argument, use it first
	downloadsPath := ""
	if len(os.Args) > 1 {
		downloadsPath = os.Args[1]
		fmt.Printf("Using directory %s\n", downloadsPath)
	} else {
		// 1. Get the user's home directory
		homeDir, err := os.UserHomeDir()
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error al obtener el directorio de inicio: %v\n", err)
			return
		}
		// 2. Build the path to the "Downloads" directory
		downloadsPath = filepath.Join(homeDir, "Downloads")
	}

	// Read the files in the Downloads directory
	files, err := os.ReadDir(downloadsPath)
	if err != nil {
		fmt.Println(err)
		return
	}

	// Create a dictionary to store files by extension
	fileExtensionDict := make(map[string][]string)

	for _, file := range files {

		// Skip directories
		if file.IsDir() {
			continue
		}
		// Get the file extension
		key := filepath.Ext(file.Name())
		keyClean, err := strings.CutPrefix(key, ".")
		if err != true {
			fmt.Printf("%s does not have an extension\n", file.Name())
			continue
		}

		// Exclude .DS_Store filename
		if keyClean == "DS_Store" {
			fmt.Println("Excluding .DS_Store filename")
			continue
		}
		ext := strings.ToUpper(keyClean)

		// Add the file to the dictionary
		if _, ok := fileExtensionDict[ext]; !ok {
			fileExtensionDict[ext] = []string{}
		}
		fileExtensionDict[ext] = append(fileExtensionDict[ext], file.Name())
	}

	// Create a directory for each extension in the dictionary
	for ext, files := range fileExtensionDict {
		extPath := filepath.Join(downloadsPath, ext)
		if err := os.Mkdir(extPath, 0777); err != nil {
			fmt.Println(err)
		}

		// Move all files with the current extension and date and permissions to the new directory
		for _, fileName := range files {
			srcPath := filepath.Join(downloadsPath, fileName)
			dstPath := filepath.Join(extPath, fileName)
			if err := os.Rename(srcPath, dstPath); err != nil {
				fmt.Println(err)
			}
		}

		fmt.Printf("Moved all %s files to %s\n", ext, extPath)
	}
}
