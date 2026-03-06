---
description: Generate, validate, and propose a Playwright E2E test from one or two GitLab MRs and a scenario description
agent: build
---

You are running /e2e-gen.

Arguments: $ARGUMENTS

Goal: turn one or two GitLab MR URLs and a scenario description into a validated Playwright test proposed as an MR in the E2E repository.

If $ARGUMENTS is empty, stop and return:
- a one-line explanation of required input
- 2 examples:
  - `/e2e-gen https://gitlab.com/org/project/-/merge_requests/123 "user can reset password"`
  - `/e2e-gen https://gitlab.com/org/proj/-/merge_requests/45 https://gitlab.com/org/proj/-/merge_requests/46 "admin can bulk-delete users"`

---

## Phase 1 – Gather and understand

### 1.1 Read config

Read `e2e-gen.config.json` from the opencode-commands directory (same directory as this file).
Extract:
- `e2eRepo` — local path to the Playwright E2E repository
- `repos` — map of GitLab project path → local clone path

If the file does not exist, stop with instructions to create it (see schema at the bottom of this file).

### 1.2 Parse arguments

From $ARGUMENTS:
- Extract 1–2 GitLab MR URLs (pattern: `https://.../-/merge_requests/<id>`)
- The remaining text is the **scenario description**
- If scenario description is missing, stop and ask the user for it

For each MR URL, extract:
- `projectId`: the `group/project` part of the URL
- `mergeRequestIid`: the numeric MR ID

### 1.3 Fetch MR context

For each MR, call `mcp__gitlab__get_merge_request` with `includeDiff: true`.
Collect:
- MR title, description, author
- Target branch
- Changed file paths (from the diff)
- The full diff (summarise files > 300 lines to their key hunks)

### 1.4 Checkout feature branch and read source files

For each MR:
1. Look up the source project path in the `repos` config map. If not found, stop and ask the user to add it.
2. In the local clone, run:
   ```
   git fetch origin
   git checkout <source-branch>
   ```
3. Read the changed source files that are most relevant to the scenarios (components, routes, API handlers, page objects). Limit to the files directly touched by the MR diff; do not read the entire codebase.

### 1.5 Discover E2E repo conventions

In `e2eRepo`:
1. List the top-level directory structure.
2. Read `playwright.config.ts` (or `.js`) to get `baseURL`, test directory, and any global setup/fixtures.
3. Read one or two existing spec files that are most similar to the scenarios (by route or feature name) to understand naming conventions, imports, and page-object usage.
4. Note the test directory path where new specs should be placed.

### 1.6 Live browser exploration

With the dev environment assumed to be running:

1. For each affected route identified in step 1.4:
   - Navigate to it: `mcp__chrome-devtools__navigate_page` with the route URL (constructed from `baseURL` + route path)
   - Take an a11y tree snapshot: `mcp__chrome-devtools__take_snapshot`
   - From the snapshot, extract all `data-testid` attributes, ARIA roles, button labels, form field labels, and heading text that are relevant to the scenarios
2. For dynamic states needed by the scenarios (e.g. form validation errors, modal dialogs, empty states):
   - Interact with relevant UI elements (`mcp__chrome-devtools__click`, `mcp__chrome-devtools__fill`) to trigger the state
   - Take additional snapshots to capture selectors in those states
3. Take a screenshot of each key page for human reference: `mcp__chrome-devtools__take_screenshot`

Collect the selector inventory (data-testids, roles, labels) as a structured list per route. This is the primary source of selectors for the test writer — prefer these over selectors inferred from source code.

### 1.7 Build context brief

Summarise everything into a compact brief:
- What changed in each MR (2–4 sentences per MR)
- Affected routes, components, or API endpoints
- **Selector inventory from live browser** (data-testids, roles, labels per route and state)
- Relevant source code snippets (key logic only — defer to live selectors for element targeting)
- E2E conventions (imports, fixture names, base URL, file naming pattern)
- Scenarios to cover (from user input)

Present this summary to the user and wait for confirmation or corrections before proceeding to Phase 2.

---

## Phase 2 – Write-review loop

**Iteration 1:**
1. Launch `task` → `e2e-writer` with the context brief (including the live browser selector inventory). Receive a complete `.spec.ts` file.
2. Launch `task` → `e2e-reviewer` with the context brief + the generated test file.
3. Read the reviewer's verdict.

**If verdict is NEEDS_REVISION:**
4. Launch `task` → `e2e-writer` again with the context brief + the reviewer's numbered findings. The writer produces a full rewrite applying all findings.

(Maximum 2 review iterations. After 2, proceed with the latest test file regardless of verdict.)

---

## Phase 3 – Local validation loop

1. Determine the target file path within `e2eRepo` based on E2E repo conventions (from Phase 1.5).
2. Write both files to `e2eRepo`:
   - The spec file at `<target-path>`
   - The coverage matrix at `<target-path-without-extension>.coverage.md`
3. Run the test:
   ```
   cd <e2eRepo> && npx playwright test <target-path> --reporter=line
   ```
4. **If all tests pass**: proceed to Phase 4.
5. **If tests fail**:
   - Extract the error output and failing test names.
   - For each failing test, navigate the browser to the relevant route and take a fresh snapshot:
     ```
     mcp__chrome-devtools__navigate_page → the route the test targets
     mcp__chrome-devtools__take_snapshot → live DOM in current state
     mcp__chrome-devtools__take_screenshot → visual reference
     ```
   - Launch `task` → `e2e-writer` with the context brief + the current test file + the full error output + the fresh browser snapshot. Receive a full rewrite.
   - Overwrite the file and re-run.
   - Repeat up to 3 fix attempts.
6. If tests still fail after 3 attempts, stop and present the final error + the last browser screenshot to the user with a summary of what was tried. Do not open an MR.

---

## Phase 4 – Open MR

1. Derive a branch name: `e2e/<mr-slug>-<YYYYMMDD>` where `mr-slug` is the first MR's IID and title in kebab-case, truncated to 40 chars.
2. In `e2eRepo`:
   ```
   git checkout -b <branch-name>
   git add <target-path> <coverage-matrix-path>
   git commit -m "feat(e2e): <scenario description, max 72 chars>"
   git push origin <branch-name>
   ```
3. Determine the GitLab project path for the E2E repo from its git remote URL.
4. Call `mcp__gitlab__*` to create an MR:
   - Title: `E2E: <scenario description>`
   - Description:
     - Paste the full coverage matrix table
     - Links to the source MRs
     - Note that the test was auto-generated and validated locally
   - Source branch: `<branch-name>`
   - Target branch: default branch of the E2E repo
5. Output the MR URL.

---

## Config file schema

`e2e-gen.config.json` must live in the opencode-commands directory:

```json
{
  "e2eRepo": "/absolute/path/to/e2e-repo",
  "repos": {
    "group/project": "/absolute/path/to/local/clone"
  }
}
```

Add one entry per GitLab project whose MRs you want to use with `/e2e-gen`.
