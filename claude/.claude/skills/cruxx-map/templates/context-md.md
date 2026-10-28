# <Room name>

<One line: the mode of work in this room.> Back to [map](<relative path>/CLAUDE.md).

## What happens here

<2 to 5 lines: responsibilities, inputs, outputs, who calls this code.>

```mermaid
flowchart LR
  <Only if it shows a real flow in this room: request path, pipeline stage, build step. Under ~15 nodes.>
```

## Files that matter

| Path | Role |
|---|---|
| `<path>` | <entry point / config / core logic / tests> |

## How to work here

- <Local commands, if they differ from the root ones.>
- <Patterns to copy: "new handlers follow `<path>`".>

## Avoid

> [!WARNING]
> <No-go zones in this room: generated files, migrations already applied, vendored code.>

- Do not reach into `<sibling room>/`: <reason; use its public interface instead>.

<details>
<summary>Gotchas</summary>

- <Things learned the hard way.>

</details>

<!-- cruxx-map: YYYY-MM-DD -->
