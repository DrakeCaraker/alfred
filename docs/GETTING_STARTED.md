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

In your terminal, type:

```
$ npm install -g @anthropic-ai/claude-code
```

`npm` is Node's package installer — it was included when you installed Node.js.

Verify it worked:

```
$ claude --version
1.0.0
```

> **Other install options**: Claude Code is also available as a [desktop app and web app](https://docs.anthropic.com/en/docs/claude-code/getting-started). The terminal version is what Alfred uses in its examples, but any version works.

## Step 4: Get Alfred

**If you have git** (most Mac and Linux systems do):

```
$ git clone https://github.com/DrakeCaraker/alfred.git my-project
$ cd my-project
$ git config core.hooksPath .githooks
```

`cd` means "change directory" — it moves you into the folder you just downloaded.

**If you don't have git** (common on Windows):

1. Go to [github.com/DrakeCaraker/alfred](https://github.com/DrakeCaraker/alfred)
2. Click the green **Code** button, then **Download ZIP**
3. Unzip the file and rename the folder to `my-project`
4. In your terminal, navigate to that folder:
   ```
   $ cd path/to/my-project
   ```

> **Tip**: On Mac, type `cd ` (with a space) then drag the folder from Finder into the terminal window. On Windows, right-click the folder in Explorer and choose "Open in Terminal."

## Step 5: Start Claude Code

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

See the [README](../README.md) for the full list of commands and how Alfred adapts to you.
