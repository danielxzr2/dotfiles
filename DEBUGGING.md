# Debugging in Neovim

This guide covers the [debugger](#keys) and, at the end, [resolving merge conflicts](#resolving-merge-conflicts).

The debugger is [nvim-dap](https://github.com/mfussenegger/nvim-dap) with [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui). The debug adapters (one per language) are installed by Mason the first time nvim starts. The config is in [`nvim/lua/kickstart/plugins/debug.lua`](nvim/lua/kickstart/plugins/debug.lua).

## The leader key

The leader key is **Space**. `<leader>db` means press **Space**, then **d**, then **b**, one after another (not held together). Press **Space** and wait to see what comes next: which-key lists every key, and `Space d` lists the debugger ones.

## Keys

| Keys | Action |
| --- | --- |
| `Space d b` | Toggle breakpoint on the current line |
| `Space d B` | Conditional breakpoint (stops only when the condition is true, e.g. `i == 5`) |
| `Space d c` or `F5` | Start debugging / continue to the next breakpoint |
| `Space d o` | Step **over**: run the current line, stop at the next one |
| `Space d i` | Step **into**: enter the function called on this line |
| `Space d O` | Step **out**: finish the current function, back to the caller |
| `Space d C` | Run to the line under the cursor |
| `Space d e` | Show the value of the expression under the cursor (or the visual selection) |
| `Space d l` | Run the last session again (same configuration and arguments) |
| `Space d t` | Terminate the session |
| `Space d u` | Show / hide the debug UI |
| `Space d T` | **Go only:** debug the test under the cursor |

The original kickstart `F1`/`F2`/`F3` (into/over/out) also work, but xfce4-terminal keeps `F1` for its help window, so use `Space d i` to step into.

## General workflow

1. **Open the project from its root folder** (`cd myproject && nvim file`). Several configurations use the folder nvim was started in.
2. **Set breakpoints**: move to a line and press `Space d b`. A red `●` appears in the sign column.
3. **Start** with `Space d c`. If the language has more than one way to launch, a menu asks which one.
4. **When execution stops at a breakpoint**, the UI opens:
   - **Left:** *Scopes* (local variables; press `Enter` on structs, lists, maps to expand), *Breakpoints*, *Stacks* (call stack) and *Watches* (expressions you want to keep an eye on).
   - **Bottom:** the program output (*console*) and a **REPL** where you can type any expression to see its value.
   - The current line is marked with `⭔` in the sign column.
5. **Move through the code** with `Space d o` / `d i` / `d O`, or `Space d c` to jump to the next breakpoint.
6. **Finish**: the UI closes when the program exits. `Space d t` stops it early. If it crashed with an unhandled error, press `F7` (or `Space d u`) to reopen the UI and read the output.

## Per language

### Go

**One-time setup.** Go isn't part of `install.sh --packages`, install it with:

```sh
sudo dnf install golang
```

Then open nvim once. Mason sees `go` and installs **delve** (the debugger) and **gopls** (the language server: autocomplete, go to definition, errors, format on save) in the background. Until Go is installed, both are skipped so nvim doesn't show install errors.

**Debugging a program.** For a project like:

```
myapp/
├── go.mod
└── main.go
```

1. `cd myapp && nvim main.go`.
2. Set breakpoints with `Space d b`.
3. `Space d c` and pick one:

   | Option | When to use it |
   | --- | --- |
   | **Debug** | Run the current file |
   | **Debug (Arguments)** | Same, but asks for command-line arguments first |
   | **Debug (Arguments & Build Flags)** | Also asks for build flags (e.g. `-tags=integration`) |
   | **Debug Package** | Run the whole package in the current folder (use this when `main` is split across several files) |
   | **Attach** | Attach to an already running Go process (pick it from a list) |
   | **Debug test** | Run the tests of the current package |
   | **Debug test (go.mod)** | Run the tests from the module root |

   delve compiles your program with debug info itself, there's no separate build step.
4. Inspect variables in *Scopes*, evaluate things like `len(users)` in the REPL, step with `Space d o` / `d i` / `d O`.

**Debugging one test.** Put the cursor inside a `func TestXxx(t *testing.T)` and press `Space d T`. Only that test runs, stopping at your breakpoints.

### Python

1. Set breakpoints and press `Space d c`. **Python: Launch file** runs the current file.
2. If your project has dependencies, **activate its virtualenv before starting nvim** (`source .venv/bin/activate && nvim main.py`; a conda env works too). A `.venv` folder is not detected on its own: without an active env the script runs with debugpy's own Python, which doesn't have your packages.

### JavaScript / TypeScript

1. Set breakpoints and press `Space d c`.
2. **Node: Launch file** runs the current file with Node. Node ≥ 22.18 runs `.ts` files directly (type stripping), so simple TypeScript needs no build step. Code with TS-only syntax like `enum` or decorators needs a build or `tsx`.
3. **Node: Attach to process** attaches to a program you started yourself with `node --inspect app.js` (useful for servers).

### C / C++

1. Compile with debug info and no optimizations, otherwise variables show as `<optimized out>` and stepping jumps around:

   ```sh
   gcc -g -O0 -o prog prog.c      # g++ for C++
   ```

2. Set breakpoints in the source and press `Space d c`.
3. **LLDB: Launch** asks for the executable path (`./prog`). **LLDB: Launch (args)** also asks for arguments.

### Rust

Rust isn't installed by default (`sudo dnf install rust cargo`). Then:

1. `cargo build` (debug builds have debug info).
2. `Space d c`, **LLDB: Launch**, and enter `target/debug/<your-crate>`.

### C#

Needs the .NET SDK (`sudo dnf install dotnet-sdk-8.0`). Build with `dotnet build`, then `Space d c` → **NetCoreDbg: Launch** and pick the `.dll` in `bin/Debug/net*/`.

## Troubleshooting

- **"Debug adapter didn't respond"** on the very first run: the adapter is starting for the first time. Wait and try again.
- **Nothing happens on `Space d c` in a language**: check the adapter is installed with `:Mason` (debugpy, codelldb, js-debug-adapter, netcoredbg, delve).
- **Breakpoint shows `⊘` (rejected)**: the line has no code (blank or comment), or for C/C++/Rust the program was built without `-g`.
- **Logs**: `:lua require('dap').set_log_level('TRACE')`, reproduce, then read `~/.local/state/nvim/dap.log`.

## Resolving merge conflicts

Conflicts are handled by [git-conflict.nvim](https://github.com/akinsho/git-conflict.nvim) (config in [`nvim/lua/custom/plugins/git-conflict.lua`](nvim/lua/custom/plugins/git-conflict.lua)). It highlights each conflict in the buffer and resolves it with one key.

### Keys

These keys only exist in buffers that have conflicts, so they don't change normal editing anywhere else.

| Keys | Action |
| --- | --- |
| `]x` / `[x` | Next / previous conflict in the file |
| `co` | Keep **ours** (your side) |
| `ct` | Keep **theirs** (the incoming side) |
| `cb` | Keep **both** (ours first, then theirs) |
| `c0` | Keep **none** (delete both sides) |
| `:GitConflictChooseBase` | Keep the **base** (the original code before either change) |
| `:GitConflictListQf` | Put every conflict in the repo in the quickfix list |
| `]q` / `[q` | Next / previous entry in the quickfix list |

### Reading a conflict

With `merge.conflictStyle zdiff3` (see the [README](README.md#neovim-merge-conflicts)), each conflict has three parts:

```
<<<<<<< HEAD
color = "green"          ← ours: what your branch has
||||||| 228d416
color = "red"            ← base: what the code was before both changes
=======
color = "blue"           ← theirs: what the branch you're merging has
>>>>>>> feature
```

Compare each side with the **base** to see what each branch actually changed. Here both changed `red`, so you have to decide. If only one side differs from the base, that side is usually the right one.

### Workflow

1. **Merge** as usual. Git stops and lists the conflicted files:

   ```sh
   git merge feature
   # CONFLICT (content): Merge conflict in config.go
   ```

2. **Open nvim in the repo** and list every conflict:

   ```
   nvim
   :GitConflictListQf
   ```

   The quickfix window opens with one line per conflict, across all files. Press `Enter` on one to jump to it.

3. **Resolve each conflict.** On a conflict, read the three parts, then:
   - `co`, `ct`, `cb` or `c0` if one of the options is what you want, or
   - **edit by hand** when the right answer mixes both sides: write the final code and delete the marker lines (`<<<<<<<`, `|||||||`, `=======`, `>>>>>>>`).

   Then `]x` for the next conflict in the same file, or `]q` for the next one in the quickfix list. While a file still has markers, LSP errors are hidden (the markers aren't valid code). They come back once the file is resolved, so check them before moving on.

4. **Save** each file (`:w`, or `:wa` for all).

5. **Make sure nothing is left**, then mark the files as resolved and finish the merge:

   ```sh
   git diff --check          # prints any leftover conflict markers
   git add config.go         # or: git add -u
   git merge --continue      # opens the commit message, save and quit
   ```

   Run the build/tests before `git merge --continue` if you can: a merge without conflict markers can still be broken.

**Changed your mind?** `git merge --abort` puts everything back to how it was before the merge.

### Rebase: ours and theirs are swapped

During `git rebase`, git replays **your** commits on top of the other branch, so the roles flip:

| | `git merge` | `git rebase` |
| --- | --- | --- |
| **ours** (`co`, `HEAD`) | your branch | the branch you're rebasing onto |
| **theirs** (`ct`) | the branch you're merging | your commit being replayed |

So in a rebase, `ct` keeps **your** change. The marker labels (`HEAD`, the commit name after `>>>>>>>`) tell you which is which. The steps are the same, but finish with `git add` + `git rebase --continue` (repeat for each commit that conflicts), or undo with `git rebase --abort`.

### Troubleshooting

- **Conflict not highlighted / keys don't work**: run `:GitConflictRefresh`. Files opened before the merge started may need `:e` to reload.
- **`:GitConflictListQf` is empty but git says there are conflicts**: make sure nvim was started inside the repo (`:pwd`).
- **Lost track of what's left**: `git status` lists files under *Unmerged paths* until you `git add` them.
