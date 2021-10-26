# kubectl-trace runner for Docker Desktop

`kubectl trace` is a [kubectl plugin](https://github.com/iovisor/kubectl-trace) that allows you to schedule the execution
of [bpftrace](https://github.com/iovisor/bpftrace) programs in Kubernetes cluster.

This runner will enable `kubectl trace` to support Docker Desktop. 

# How to play


```
$ kubectl trace run docker-desktop --imagename=registry.cn-hangzhou.aliyuncs.com/denverdino/kubectl-trace-runner -e "tracepoint:syscalls:sys_enter_* { @[probe] = count(); }"
trace 7b64f4b4-226e-4aaf-83b1-94858c72f91f created

$ kubectl trace attach 7b64f4b4-226e-4aaf-83b1-94858c72f91f
Attaching 327 probes...

^C
first SIGINT received, now if your program had maps and did not free them it should print them out

@[tracepoint:syscalls:sys_enter_getrlimit]: 1
@[tracepoint:syscalls:sys_enter_newstat]: 1
@[tracepoint:syscalls:sys_enter_fsync]: 1
@[tracepoint:syscalls:sys_enter_rt_sigsuspend]: 2
...

```

or you can create the short cut and play with it

```
$ alias kubectl-trace-run="kubectl trace run --imagename=registry.cn-hangzhou.aliyuncs.com/denverdino/kubectl-trace-runner"
$ kubectl-trace-run docker-desktop -e 'tracepoint:syscalls:sys_enter_open { printf("%s %s\n", comm, str(args->filename)); }'
trace 96209723-f439-4fb8-8bdc-d32e41e53e35 created

$ kubectl trace attach 96209723-f439-4fb8-8bdc-d32e41e53e35
Attaching 1 probe...
sntpc /etc/services
sntpc /dev/urandom
sntpc /dev/urandom
...

```

# How to build

```
docker build -t registry.cn-hangzhou.aliyuncs.com/denverdino/kubectl-trace-runner .
```

## Reference

[eBPF for Docker Desktop on macOS](https://github.com/singe/ebpf-docker-for-mac)
