# GitHub Account Setup

Guide new users through checking for a GitHub account, creating one if needed, authenticating, and creating a repository for their project. This command assumes the user knows nothing about GitHub and explains every step in plain language.

This command is called automatically during `/bootstrap` (Step 1.5) but can also be run standalone.

## Why This Exists

Many Alfred users — especially those in data science, research, and analytics — have never used GitHub. They don't know what it is, why they need it, or how to set it up. This command bridges that gap with zero assumptions.

## Step 1: Explain What GitHub Is and Why They Need It

Before checking anything technical, explain in plain language:

```
Before we set up your project, let's make sure you have a GitHub account.

**What is GitHub?**
GitHub is like a secure online backup for your code — but smarter. It:
- Saves every version of your work (so you can undo mistakes)
- Lets you collaborate with others without overwriting each other's work
- Keeps your code safe even if your computer breaks

**Why do you need it?**
Alfred uses GitHub to:
- Back up your code automatically
- Create safe "branches" so you can experiment without breaking anything
- Share your work via pull requests (a way to propose changes)
- Run automatic checks on your code before it goes live

Think of it like Google Docs version history, but for code. You won't need
to understand all of GitHub right away — Alfred handles the complicated parts.
```

## Step 2: Check if GitHub CLI is Installed

```bash
which gh 2>/dev/null
gh --version 2>/dev/null
```

**If `gh` is NOT installed**, guide them through installation:

```
GitHub's command-line tool (gh) isn't installed yet. This is the tool Alfred
uses to talk to GitHub on your behalf.

**To install it:**

- **Mac**: Open Terminal and run:
    brew install gh

- **Windows**: Open PowerShell and run:
    winget install --id GitHub.cli

- **Linux (Ubuntu/Debian)**:
    sudo apt install gh

- **Linux (Fedora)**:
    sudo dnf install gh

- **Other**: Visit https://cli.github.com and follow the instructions
  for your system.

Once installed, tell me and we'll continue.
```

Wait for the user to confirm installation, then re-check with `gh --version`.

## Step 3: Check if User is Authenticated

```bash
gh auth status 2>&1
```

**If authenticated**: Extract the username and skip to Step 6.

```
Great — you're already logged into GitHub as [username]. Let's keep going.
```

**If NOT authenticated**: Proceed to Step 4.

## Step 4: Check if They Have a GitHub Account

Ask the user directly:

```
Do you already have a GitHub account?

1. Yes — I have an account
2. No — I need to create one
3. I'm not sure
```

### If "Yes" or "Not sure":

```
Let's try logging in. I'll open a browser window where you can sign in to GitHub.
This connects your computer to your GitHub account so Alfred can back up your work.
```

Run:
```bash
gh auth login --web -p https
```

Walk them through what they'll see:
```
Here's what will happen:
1. Your browser will open to a GitHub page
2. It will show a code — make sure it matches the one displayed in your terminal
3. Click "Authorize" to give this computer permission to use your GitHub account
4. Come back here when you see "Authentication complete" in the terminal

If your browser doesn't open automatically, copy the URL shown in the terminal
and paste it into your browser.
```

After auth completes, verify:
```bash
gh auth status 2>&1
```

If auth failed, help troubleshoot:
```
Authentication didn't work. A few things to check:
- Make sure you clicked "Authorize" in the browser
- If the page expired, we can try again
- If you're behind a company firewall/VPN, you may need to ask your IT team

Want to try again?
```

### If "No" — They Need to Create an Account:

```
No problem! Creating a GitHub account is free and takes about 2 minutes.

**Here's what to do:**

1. Open your browser and go to: https://github.com/signup
2. Enter your email address
3. Create a password (use a strong one!)
4. Choose a username — this is your public identity on GitHub
   - Keep it professional (e.g., your name or initials + topic)
   - Examples: jsmith-data, maria-research, alex-analytics
5. Complete the verification puzzle
6. Check your email and click the confirmation link

**Important**: Pick a username you'd be comfortable putting on a resume.
Your GitHub profile can become a portfolio of your work over time.

Once you've created your account and confirmed your email, come back here
and tell me. We'll connect it to your computer next.
```

Wait for confirmation, then run `gh auth login --web -p https` and walk them through Step 4's auth flow.

## Step 5: Verify Authentication Succeeded

```bash
gh auth status 2>&1
```

Extract and store the username. Confirm:

```
You're connected to GitHub as [username]. Everything from here is automatic.
```

If this still fails after multiple attempts:

```
We're having trouble connecting. This is unusual but not a dead end.
You can continue setting up your project locally for now, and we'll
connect to GitHub later.

Your work won't be lost — it's still saved on your computer.
We just won't be able to back it up online until this is resolved.

Common fixes:
- Restart your terminal and try: gh auth login
- Check if your company blocks GitHub (ask IT)
- Try again on a different network (e.g., not company WiFi)

When you're ready to try again, run: /github-account-setup
```

Set a flag in onboarding state and continue bootstrap without GitHub.

## Step 6: Check for Existing Repository

Only run this step if a project name/description is available (from bootstrap Q3 or ask now).

```bash
# Check if current directory already has a remote
git remote -v 2>/dev/null

# Check if the user has repos with a similar name
gh repo list --limit 100 --json name,url 2>/dev/null
```

**If a remote already exists**: Confirm and skip to end.

```
This project is already connected to a GitHub repository:
  [remote URL]

You're all set — Alfred will use this for backups and collaboration.
```

**If no remote exists**: Proceed to Step 7.

## Step 7: Create a Repository

Ask the user:

```
Your project isn't backed up to GitHub yet. Want me to create a
repository (a project folder on GitHub) for it?

1. Yes — create it for me (recommended)
2. No — I'll do it later
```

### If "Yes":

Determine the repo name from the project directory name or ask:

```
What should we call this repository?
(Default: [current-directory-name])

Just press Enter to use the default, or type a different name.
```

Then ask about visibility:

```
Should this repository be:

1. Private — only you can see it (recommended for most projects)
2. Public — anyone on the internet can see your code

If you're not sure, go with Private. You can change this later.
```

Create the repository:

```bash
# For private:
gh repo create [repo-name] --private --source=. --push

# For public:
gh repo create [repo-name] --public --source=. --push
```

If creation succeeds:

```
Done! Your repository is created and your code is backed up to:
  https://github.com/[username]/[repo-name]

From now on, Alfred will:
- Create branches for new work (keeps your main code safe)
- Commit your changes with clear descriptions
- Push backups to GitHub automatically
- Open pull requests when your work is ready for review

You don't need to remember any of this — Alfred handles it.
```

If creation fails:

```bash
# Check if name is taken
gh repo view [username]/[repo-name] 2>&1
```

If name conflict:
```
That repository name is already taken on your account.
Want to use a different name? (Suggest: [repo-name]-v2 or [repo-name]-project)
```

If other error:
```
Couldn't create the repository. Error: [error message]

This might be a permissions issue. Try:
1. Run: gh auth refresh
2. Then tell me to try again

Or we can skip this for now and create the repo later with: /github-account-setup
```

### If "No" or skipped:

```
No problem. Your code is saved locally on your computer.
When you're ready to back it up to GitHub, just run: /github-account-setup

Note: Without GitHub, some Alfred features are limited:
- /pr (pull requests) won't work
- /ci-fix (automatic code checks) won't work
- Code isn't backed up offsite

Everything else works fine locally.
```

## Step 8: Update Onboarding State

After completion, update `.claude/.onboarding-state.json` to include GitHub status:

```json
{
  "github": {
    "authenticated": true,
    "username": "<github-username>",
    "repo_created": true,
    "repo_url": "https://github.com/<username>/<repo-name>",
    "setup_completed_at": "<ISO-8601 timestamp>"
  }
}
```

If GitHub setup was skipped or failed:

```json
{
  "github": {
    "authenticated": false,
    "username": null,
    "repo_created": false,
    "repo_url": null,
    "setup_completed_at": null,
    "skipped": true,
    "skip_reason": "user_declined|auth_failed|gh_not_installed"
  }
}
```

## Rules

- **Never rush the user.** If they need to create an account, let them take their time.
- **Never assume technical knowledge.** Explain browser, terminal, URL — everything.
- **Never store or ask for passwords.** `gh auth login --web` handles auth via browser, not CLI.
- **Never create a public repo without explicit confirmation.** Default to private.
- **Always offer an escape hatch.** Every step can be skipped and revisited later.
- **Always verify after each step.** Don't assume auth or repo creation worked — check.
- **If gh is not installed and user can't install it**, don't block bootstrap. Note it and move on.
- **Be encouraging.** For beginners, GitHub can feel intimidating. Keep the tone supportive.
- **Re-run safely.** This command can be run multiple times — it detects existing state and skips completed steps.
