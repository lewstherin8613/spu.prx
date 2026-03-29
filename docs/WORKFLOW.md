# Workflow

## Per-function Documentation Process

For each function in `spu.elf.c`, document:

1. Current decompiler name and address.
2. What class of function it is:
   - startup / CRT
   - import trampoline
   - synchronization helper
   - queue helper
   - scheduler helper
   - worker entry / state machine
   - job implementation
   - math / utility
3. Inputs and outputs.
4. Side effects:
   - TLS writes
   - queue mutation
   - event flag signaling
   - scheduler state transitions
5. Callers and callees worth following.
6. Best current semantic description.
7. Confidence level:
   - low
   - medium
   - high
8. Rename candidate, if justified.
9. Open questions.

## Rules

- Preserve the original decompiler name until a better name is defensible.
- Call out uncertainty explicitly.
- Prefer explaining behavior over guessing intent.
- Separate proven behavior from inference.
- Keep notes clean-room friendly.

## Recommended Order

- Follow file order.
- Finish small wrappers and scheduler helpers first.
- Use later large functions only to refine earlier notes when necessary.

