# Getting Started with Alfred (from scratch)

This guide walks you through setting up Alfred with no prior experience. If you already know your way around a terminal, the [README](../README.md#setup) has a faster version.

## What you'll need

- A computer (Mac, Windows, or Linux)
- A paid Claude Code subscription — pick one:
  - **Claude Max or Team** (simplest) — sign up at [claude.ai](https://claude.ai). Claude Code will log you in through your browser.
  - **Anthropic API key** (pay-per-use) — create one at [console.anthropic.com](https://console.anthropic.com).

## Step 1: Open a terminal

A terminal is a text-based interface where you type commands and press Enter to run them. Here's how to open one:

- **Mac**: press Cmd+Space, type `Terminal`, press Enter
- **Windows**: press the Windows key, type `PowerShell`, press Enter
- **Linux**: press Ctrl+Alt+T (or search for "Terminal" in your app menu)

You'll see a window with a blinking cursor. This is where you'll type the commands in the following steps.

> In the examples below, lines starting with `$` are commands you type (don't type the `$` itself). Lines without `$` are output you'll see.

## Step 2: Install Node.js

Node.js is a tool that Claude Code needs in order to run. You only install it once.

1. Go to [nodejs.org](https://nodejs.org)
2. Download the **LTS** version (the big green button)
3. Run the installer and accept the defaults

Verify it worked:

```
$ node --version
v22.0.0
```

The version number may differ — any number is fine.

## Step 3: Install Claude Code

Claude Code is the AI tool Alfred runs on. Install it once:

**Option A — Direct install (recommended):**

Visit [docs.anthropic.com/en/docs/claude-code](https://docs.anthropic.com/en/docs/claude-code) and follow the installation instructions for your system.

**Option B — Via npm:**

```
$ npm install -g @anthropic-ai/claude-code
```

Verify it worked:

```
$ claude --version
```

## Step 4: Get Alfred

**Option A — Install as a plugin (recommended):**

Start Claude Code in any project:
```
$ claude
```

Then inside Claude Code, type:
```
/plugin marketplace add DrakeCaraker/alfred
/plugin install alfred@alfred-marketplace
/reload-plugins
```

That's it — Alfred is now available in all your projects. Skip to Step 6.

**Option B — Clone as a template project:**

If you want to start a brand new project based on Alfred:

```
$ git clone https://github.com/DrakeCaraker/alfred.git my-project
$ cd my-project
$ make setup
```

> `make setup` activates Alfred's safety checks — they block accidental pushes to the main version of your project and prevent large binary files from being saved.

## Step 5: Start Claude Code

> If you installed via plugin (Option A above), you're already in Claude Code. Skip to Step 6.

Type:

```
$ claude
```

Claude Code starts up. You'll see a status summary — this is Alfred checking its setup. It will say something about not being bootstrapped yet. This is normal.

You are now at the **Claude Code prompt**. This is different from your terminal:

| | Terminal | Claude Code |
|---|---------|-------------|
| **What it is** | Your computer's command line | An AI assistant you talk to |
| **What you type** | System commands (`cd`, `npm`, `git`) | Messages and slash commands (`/bootstrap`) |
| **How to tell** | Shows `$` or `>` with your username | Shows the Claude Code interface |
| **How to exit** | Close the window | Type `/exit` or press Ctrl+C twice |

From here on, everything you type goes to Claude Code, not your terminal.

## Step 6: Run /bootstrap

At the Claude Code prompt, type:

```
/bootstrap
```

> **If you installed via plugin (Option A):** All Alfred commands use the `alfred:` prefix. Type `/alfred:bootstrap` instead. This applies to every Alfred command: `/alfred:teach`, `/alfred:status`, etc.

Alfred asks three questions. Type your answer and press Enter after each:

```
What best describes your work?
  1. ML / Data Science
  2. Research
  3. Business Analytics
  4. Product Analytics
  5. BI Platform
  6. General
> 1

How comfortable are you with coding?
  1. Beginner
  2. Intermediate
  3. Advanced
> 1

Describe your project in one sentence:
> quarterly revenue forecasting model
```

Pick whatever fits — there are no wrong answers. Alfred uses this to customize its language and guardrails for you.

It may offer to set up a GitHub account. You can skip this for now and do it later with `/github-account-setup`.

When it finishes, you'll see:

```
Done. CLAUDE.md generated, guardrails active, 0/8 patterns learned.
Start working — I'll explain things as they come up.
```

## You're set up

Just describe what you want to build. Alfred will guide you from here.

Three things you can try:

- **Start working** — type what you want to do in plain language, like "create a Python script that reads a CSV file"
- **Run `/teach`** — learn your first development pattern
- **Run `/status`** — see your progress

> **Want to level up fast?** Read the [Prompting Guide](PROMPTING_GUIDE.md) for tips on getting the best results from Claude Code in your domain.

See the [README](../README.md) for the full list of commands and how Alfred adapts to you.
