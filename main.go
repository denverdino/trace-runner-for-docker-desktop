package main

import (
	"log"
	"os"
	"os/exec"

	"github.com/iovisor/kubectl-trace/pkg/cmd"
	"github.com/spf13/pflag"
)

func main() {
	flags := pflag.NewFlagSet("trace-runner", pflag.ExitOnError)
	pflag.CommandLine = flags

	command := exec.Command("mount", "-t", "debugfs", "debugfs", "/sys/kernel/debug")
	err := command.Run()
	if err != nil {
		log.Fatalf("Failed to mount debugfs %s\n", err)
	}

	root := cmd.NewTraceRunnerCommand()
	if err := root.Execute(); err != nil {
		os.Exit(1)
	}
}
