# Overview

## Current Read

The PS4 `spu.prx` appears to be a native worker module paired with a host-side scheduler in `eboot.bin.c`.

The current working model is:

1. `eboot` owns the host runtime object, queue registration, submission helpers, and wake-up logic.
2. `spu.prx` owns the worker entrypoint, TLS-backed worker context, queue claiming, and native job dispatch/state-machine execution.
3. PS3-era script/job content may be preserved at the data level, but execution is performed by PS4 native code rather than PS3 SPU hardware.

## Strong Signals

- `eboot` creates a `"spurs"` mutex and `"SpuEventFlag"` event flag.
- `eboot` spawns 5 worker threads backed by direct memory.
- `eboot` builds 16 `Wws_Job`-style queue descriptors.
- `spu.prx` exports the worker proc used by those threads.
- `spu.prx` worker code waits on event flags, scans queue slots, claims work atomically, and dispatches native handlers.

## Immediate Documentation Targets

- startup and import trampolines
- scheduler state helpers
- queue accounting helpers
- queue fetch / claim logic
- worker state machine initialization
