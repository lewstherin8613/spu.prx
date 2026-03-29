# Research Log

## 2026-03-29

### Initial structural findings

- `spu.elf.c` contains 387 decompiler function blocks.
- The file is better treated as decompiled `spu.prx`, not a literal PS3-style SPU image.
- `eboot.bin.c` creates the host runtime object, named `"spurs"`, with `"SpuEventFlag"` and 5 worker threads.
- `eboot.bin.c` registers 16 `Wws_Job`-style queue descriptors.
- `spu.prx` exports the worker entry used by the host runtime.

### Immediate next steps

- generate and freeze a function index
- document the top-of-file startup and scheduler helpers
- map the packed queue counter format used by `sub_230` / `sub_290`
- confirm scheduler state fields around offsets `10860` through `11156`

