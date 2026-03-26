# Pilot Data Deletion

Delete your pilot telemetry and feedback data.

## Arguments

$ARGUMENTS — optional: `local` (local only) or `remote` (create PR to remove from repo). Default: `remote`.

## Algorithm

1. **Determine scope**:
   - If argument is `local`, go to step 3 (local wipe only)
   - Otherwise, proceed with remote deletion (which includes local wipe)

2. **Read identity**:
   - Read UUID from `.claude/.pilot-identity.json`
   - If file missing, ask: "Identity file not found. Enter your anonymous UUID to delete remote data, or say 'cancel'."
   - If cancelled, stop.

3. **Local wipe** (for `local` scope):
   - Show what will be deleted:
     - `.pilot/telemetry/<uuid>.json` (if exists)
     - `.pilot/feedback/<uuid>-*.md` (list matching files)
     - `.claude/.pilot-consent.json`
     - `.claude/.pilot-identity.json`
     - `.claude/.pilot-session-start`
     - `.claude/.pilot-nudge-count`
   - Ask: "Delete all listed files? (yes/no)"
   - If no, stop.
   - Delete the files
   - Confirm: "Local data deleted. Run /pilot-delete remote to remove from repo history."
   - Stop.

4. **Check for gh CLI**:
   - Run: `which gh`
   - If not found:
     - Say: "GitHub CLI (gh) not found. Manual steps:"
     - Print instructions to manually create a branch, git rm files, commit, and open PR
     - Stop.

5. **Show deletion plan**:
   - List all `.pilot/telemetry/<uuid>.json` and `.pilot/feedback/<uuid>-*.md` files
   - Ask: "This will create a PR to remove these files from the repo. Continue? (yes/no)"
   - If no, stop.

6. **Create deletion PR**:
   - Create branch: `chore/pilot-data-removal-<first 8 chars of uuid>`
   - `git rm` matching files in `.pilot/`
   - Commit: `chore: remove pilot data for participant <uuid>`
   - Push with `-u`
   - Create PR with `gh pr create`:
     - Title: `chore: remove pilot data for participant <short-uuid>`
     - Body:
       ```
       ## Pilot Data Removal Request

       Removing telemetry and feedback data for anonymous participant.

       ### Files removed
       - <list of removed files>

       ### Complete history removal
       To fully remove from git history (repo owner action):
       ```
       git filter-repo --path <file1> --path <file2> --invert-paths
       ```

       Note: History removal requires force-push to main and is a destructive operation.
       Only the repo owner should perform this step.
       ```

7. **Local cleanup**:
   - Delete local consent, identity, session-start, and nudge-count files
   - Confirm: "PR created: <PR URL>. Local data also deleted."
