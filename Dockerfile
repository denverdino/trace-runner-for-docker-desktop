# syntax = docker/dockerfile:1.2
ARG bpftraceversion=v0.13.0
ARG bccversion=v0.21.0-focal-release
ARG rbspyversion=0.8.0
FROM quay.io/iovisor/bpftrace:$bpftraceversion as bpftrace
FROM quay.io/iovisor/bcc:$bccversion as bcc
FROM rbspy/rbspy:$rbspyversion-gnu as rbspy

FROM golang:1.15-buster as gobuilder
ARG GIT_ORG=iovisor
ENV GIT_ORG=$GIT_ORG
RUN apt-get update && apt-get install -y make bash git && apt-get clean

WORKDIR /go/src/github.com/denverdino/trace-runner-for-docker-desktop

# first copy the go mod files and sync the module cache as this step is expensive
COPY go.* .
COPY *.go .
RUN go env -w GOPROXY=https://mirrors.aliyun.com/goproxy/,direct && go mod download

# Now copy the rest of the source code one by one
# note any changes in any of these files or subdirectories is expected to bust the cache
# We copy only the code directories, makefile, and git directory in order to prevent
# busting the cache. Due to limitations in docker syntax, this must be done one-per-line

# This buildkit feature reduces the build time from ~50s → 5s by preserving the compiler cache
RUN CGO_ENABLED=1 go build ${LDFLAGS} -o $@ ./trace-runner

FROM docker/for-desktop-kernel:5.10.47-0b705d955f5e283f62583c4e227d64a7924c138f AS ksrc
FROM quay.io/iovisor/kubectl-trace-runner

# Add kernel headers for Docker Desktop
COPY --from=ksrc /kernel-dev.tar /
RUN tar xf kernel-dev.tar && rm kernel-dev.tar


COPY --from=gobuilder /go/src/github.com/denverdino/trace-runner-for-docker-desktop/trace-runner /bin/trace-runner
