# LBP3 PS4 `spu.prx` Reverse Engineering

This repo is a focused workspace for understanding, documenting, and eventually clean-room reimplementing the PS4 `spu.prx` module used by LittleBigPlanet 3.

## Goals

- Build a complete function inventory for the decompiled `spu.prx`.
- Document every function in `spu.elf.c` from top to bottom.
- Recover the host-side ABI between `eboot.bin.c` and `spu.prx`.
- Map the queueing, scheduling, worker, and job-dispatch systems.
- Create a clean-room foundation for a future reimplementation in another project.

## Non-goals

- Copying proprietary source.
- Mixing this effort into unrelated recompilation work.
- Pretending uncertain reverse-engineering results are final facts.

## Current Assumptions

- The working decompilation for the PS4 PRX lives at `..\\ps4_ref\\spu.elf.c`.
- `spu.elf.c` is the decompiler output for the PS4 `spu.prx` module.
- The host-side scheduler/runtime lives in `..\\ps4_ref\\eboot.bin.c`.

## Project Layout

- `docs/OVERVIEW.md`: high-level architecture notes.
- `docs/WORKFLOW.md`: function-by-function documentation process.
- `docs/RESEARCH_LOG.md`: running investigation log.
- `docs/FUNCTION_INDEX.md`: generated index of every function in `spu.elf.c`.
- `docs/FUNCTION_NOTES.md`: manual documentation, starting from the top of the file.
- `scripts/extract_function_index.ps1`: rebuilds the function inventory from the decompilation.

## Initial Objective

Document every function in `spu.elf.c` incrementally, beginning at the top of the file, while preserving:

- current decompiler names
- discovered semantics
- confidence level
- dependencies and call relationships
- rename candidates
