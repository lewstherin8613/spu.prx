# Function Notes

This document is the manual reverse-engineering track. It starts at the top of `spu.elf.c` and will grow incrementally.

## `start` at `0x00000000`

- Type: startup / module entry wrapper
- Confidence: high
- Summary: walks constructor/init arrays, then dispatches into the provided startup callback or `module_start`.
- Inputs:
  - `a1`, `a2`: forwarded startup arguments
  - `a3`: optional startup callback
- Behavior:
  - walks forward through one init-array-like table
  - walks backward through another init/fini-style table
  - calls `a3(a1, a2)` if present
  - otherwise calls `module_start(a1, a2)` if the module advertises one
- Notes:
  - this is standard PRX/ELF startup glue, not game logic

## `sub_E6` at `0x000000E6`

- Type: import trampoline
- Confidence: high
- Summary: tail-call style stub through `qword_701D0`.
- Notes:
  - identical pattern to the following early stubs
  - should not be treated as meaningful logic until the import is identified

## `sub_F6` at `0x000000F6`

- Type: import trampoline
- Confidence: high
- Summary: same import stub pattern as `sub_E6`.

## `sub_106` at `0x00000106`

- Type: import trampoline
- Confidence: high
- Summary: same import stub pattern as `sub_E6`.

## `sub_116` at `0x00000116`

- Type: import trampoline
- Confidence: high
- Summary: same import stub pattern as `sub_E6`.

## `sub_126` at `0x00000126`

- Type: import trampoline
- Confidence: high
- Summary: same import stub pattern as `sub_E6`.

## `sub_136` at `0x00000136`

- Type: import trampoline
- Confidence: high
- Summary: same import stub pattern as `sub_E6`.

## `sub_146` at `0x00000146`

- Type: import trampoline
- Confidence: high
- Summary: same import stub pattern as `sub_E6`.

## `sub_156` at `0x00000156`

- Type: import trampoline
- Confidence: high
- Summary: same import stub pattern as `sub_E6`.

## `sub_166` at `0x00000166`

- Type: import trampoline
- Confidence: high
- Summary: same import stub pattern as `sub_E6`.

## `sub_176` at `0x00000176`

- Type: import trampoline
- Confidence: high
- Summary: same import stub pattern as `sub_E6`.

## `sub_186` at `0x00000186`

- Type: import trampoline
- Confidence: high
- Summary: same import stub pattern as `sub_E6`.

## `sub_196` at `0x00000196`

- Type: import trampoline
- Confidence: high
- Summary: same import stub pattern as `sub_E6`.

## `sub_1A6` at `0x000001A6`

- Type: import trampoline
- Confidence: high
- Summary: same import stub pattern as `sub_E6`.

## `sub_1B6` at `0x000001B6`

- Type: import trampoline
- Confidence: high
- Summary: same import stub pattern as `sub_E6`.

## `sub_1C6` at `0x000001C6`

- Type: import trampoline
- Confidence: high
- Summary: same import stub pattern as `sub_E6`.

## `sub_1D6` at `0x000001D6`

- Type: import trampoline
- Confidence: high
- Summary: same import stub pattern as `sub_E6`.

## `sub_1E6` at `0x000001E6`

- Type: import trampoline
- Confidence: high
- Summary: same import stub pattern as `sub_E6`.

## `sub_1F6` at `0x000001F6`

- Type: import trampoline
- Confidence: high
- Summary: same import stub pattern as `sub_E6`.

## `sub_200` at `0x00000200`

- Type: thin wrapper
- Confidence: high
- Summary: forwards to `sub_1E70` and returns the original destination pointer.
- Inputs:
  - `a1`: destination context/output object
  - `a3`, `a4`, `a5`, `a6`: forwarded configuration fields
- Notes:
  - `a2` is present in the signature but unused in the decompiled body
  - likely a convenience constructor/wrapper around the fuller initializer

## `sub_230` at `0x00000230`

- Type: synchronization / packed-counter helper
- Confidence: medium
- Summary: atomically subtracts `a2` from the low 16 bits of a packed state word and triggers scheduler signaling when the count reaches zero.
- Inputs:
  - `a1`: pointer to packed atomic state
  - `a2`: decrement amount
- Behavior:
  - preserves the upper bytes of the packed state
  - when the low counter becomes zero and a secondary field is non-zero, calls `sub_4220`
- Working interpretation:
  - low 16 bits: outstanding dependency count or tickets
  - upper bytes: queue index / signal payload

## `sub_290` at `0x00000290`

- Type: synchronization / packed-counter helper
- Confidence: medium
- Summary: specialized version of `sub_230` that decrements the low 16-bit count by one.
- Behavior:
  - same zero-crossing wake-up behavior as `sub_230`
- Relationship:
  - likely the common completion path for a single finished sub-task

## `sub_2F0` at `0x000002F0`

- Type: queue fetch / claim helper
- Confidence: medium
- Summary: locks a queue-like object, reads the next 16-byte entry from the current stream, and updates per-lane cursors and watermarks based on the entry opcode.
- Inputs:
  - `a1`: output record
  - `a2`: queue/control object
  - `a3`: lane or worker selector
- Interesting behavior:
  - reads an entry header and payload pointer
  - switches on a 16-bit opcode at `a1 + 2`
  - updates per-lane min/max cursor tracking
  - returns immediately for opcode `0` and for opcode `1`
- Open question:
  - the exact opcode meanings still need names

## `sub_410` at `0x00000410`

- Type: worker-local execution-context initializer
- Confidence: medium-high
- Summary: resets a large worker-local state block, records the current worker/job identity from TLS-backed helpers, and initializes scheduler scratch fields.
- Behavior:
  - stores the caller identity/context
  - snapshots current job index via `sub_41E0`
  - snapshots current worker id via `sub_4200`
  - zeros several state arrays
  - initializes sentinel fields to `-1`, `0xFFFF`, or `255`
- Notes:
  - this looks like the top-level reset before a worker executes a claimed job

## `sub_610` at `0x00000610`

- Type: event-bit setter
- Confidence: medium-high
- Summary: sets a worker-local pending-event bit in the scheduler state.
- Behavior:
  - `state[11156] |= 1 << a1`
- Notes:
  - consumed later by `sub_640`

## `sub_640` at `0x00000640`

- Type: scheduler event pump
- Confidence: medium-high
- Summary: consumes pending event bits, advances scheduler state transitions, and may trigger `sub_6F0`, `sub_850`, or `sub_BB0`.
- Behavior:
  - drains a bitfield at offset `11156`
  - promotes state `1 -> 2` when bit `0` is seen
  - handles extra work flags `0x20` and `0x40`
  - may request or enqueue another work item via `sub_BB0`
- Notes:
  - this is a central "process pending scheduler work" helper

## `sub_6E0` at `0x000006E0`

- Type: trivial helper
- Confidence: high
- Summary: returns constant `1`.
- Notes:
  - likely a callback or table filler

## `sub_6F0` at `0x000006F0`

- Type: queue maintenance / work preparation
- Confidence: medium
- Summary: scans the active lane table for entries flagged with bit `2`, performs `sub_2D60` work on them, and re-arms scheduler work if any progress was made.
- Behavior:
  - iterates a table derived from the active scheduler slot
  - only processes entries with bit `2` set
  - calls `sub_2D60(...)`
  - if any call succeeds, sets scheduler pending flag `0x20`
- Open question:
  - whether this is best described as "prepare DMA-like transfers", "materialize job fragments", or "expand command groups"

## `sub_850` at `0x00000850`

- Type: completion / retirement handler
- Confidence: medium
- Summary: retires the current active scheduler slot, clears entry flags, writes back minimum cursor data, releases dependency counters, and clears the active-slot marker.
- Behavior:
  - walks the active entry table
  - handles special flags `1` and `0x10`
  - updates the shared queue cursor under a mutex
  - decrements dependency counters through `sub_290`
  - clears `active_slot`
- Notes:
  - this looks like the "job/group finished" cleanup path

## `sub_AA0` at `0x00000AA0`

- Type: scheduler enqueue helper
- Confidence: medium
- Summary: builds a small scheduling descriptor and forwards it to `sub_BB0`; on failure it forces scheduler state `3`.

## `sub_AF0` at `0x00000AF0`

- Type: scheduler main loop helper
- Confidence: medium
- Summary: repeatedly pumps pending scheduler events and tries to obtain work through `sub_BB0`, invoking `sub_850` when an active slot exists.
- Notes:
  - likely one of the higher-level scheduling loops beneath the worker entry

## `sub_BB0` at `0x00000BB0`

- Type: scheduler core allocator / selector
- Confidence: low-medium
- Summary: large scheduler routine that appears to choose or install the next active work slot from a set of candidate tables.
- Notes:
  - this is one of the first major "rename me later" functions
  - it likely deserves a dedicated pass before we rename any surrounding state

