# Python Workspace Setup: Detailed Explanation

This document walks through each step in the `setup_python_workspace.sh` script, explaining **why** it’s important and **what** happens during the installation.

---

## 1. Install Homebrew if missing

**Why it’s important**  
Homebrew is the de-facto package manager on macOS. It lets you install and update system tools (like Git, Node.js, Python toolchains) without requiring `sudo` or touching Apple’s protected system files.

**What’s going on**  
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew doctor
```
- Downloads and runs the official Homebrew installer.  
- `brew doctor` checks your system for potential issues.  
- If Homebrew is already installed, these commands detect that and skip reinstallation.

---

## 2. Install required packages via Homebrew

**Why it’s important**  
You need command-line tools to manage Python versions (`pyenv`), create virtual environments (`pyenv-virtualenv`), handle Git repositories (`git`), and build JupyterLab extensions (`node`).

**What’s going on**  
```bash
brew install git pyenv pyenv-virtualenv node
```
- **git**: version control system for tracking code changes.  
- **pyenv**: installer and switcher for multiple Python versions.  
- **pyenv-virtualenv**: plugin to create isolated Python environments.  
- **node**: provides `node` and `npm` so JupyterLab can build front-end extensions and determine build status.

---

## 3. Configure pyenv in your shell

**Why it’s important**  
Your shell needs to load pyenv’s “shims” (so `python` maps to the correct version) and enable the virtualenv plugin automatically when you start a session.

**What’s going on**  
- **Login shells (`~/.zprofile`)**:
  ```bash
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init --path)"
  fi
  ```
  Ensures the `pyenv` command is on your `PATH` as soon as you open Terminal.

- **Interactive shells (`~/.zshrc`)**:
  ```bash
  if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
  fi
  ```
  - `pyenv init -` sets up shims for `python`, `pip`, etc.  
  - `pyenv virtualenv-init -` loads the plugin so you can `pyenv activate` environments.

After editing those files, running `exec "$SHELL" -l` reloads your shell and applies the changes immediately.

---

## 4. Install Python 3.11.5 & create a virtualenv

**Why it’s important**  
A dedicated interpreter and isolated environment prevent conflicts with other projects or the system Python. Pinning to 3.11.5 ensures consistency across machines and collaborators.

**What’s going on**  
```bash
pyenv install -s 3.11.5
pyenv virtualenv -f 3.11.5 my-project-venv
pyenv local my-project-venv
```
- `install -s`: only install if not already present.  
- `virtualenv -f`: force creation of `my-project-venv` from Python 3.11.5.  
- `local`: writes a `.python-version` file so any shell in this directory auto-activates the venv.

---

## 5. Install Poetry

**Why it’s important**  
Poetry is a modern dependency manager and packager. It creates its own venv, locks dependencies reproducibly, and can publish your project to PyPI.

**What’s going on**  
```bash
curl -sSL https://install.python-poetry.org | python3 -
export PATH="$HOME/.local/bin:$PATH"
```
- Downloads and runs Poetry’s official installer.  
- Adds the `poetry` binary to your `PATH`.  

---

## 6. Re-enable `poetry shell` (optional)

**Why it’s important**  
Poetry 2.x no longer bundles the `poetry shell` command by default. If you prefer spawning a subshell within your project venv, this restores that functionality.

**What’s going on**  
```bash
poetry self add poetry-plugin-shell || true
```
- Installs the official `shell` plugin.  
- `|| true` ensures the script continues even if you’ve already added it.

---

## 7. Make sure this is a Git repo

**Why it’s important**  
Pre-commit hooks need a `.git` folder to install their scripts into `.git/hooks`. Initializing Git also gives you version history right away.

**What’s going on**  
```bash
git init
git add .
git commit -m "Initial commit for pre-commit"
```
- `git init` creates the repo if it doesn’t already exist.  
- Stages all files and makes the first commit so pre-commit can hook into it.

---

## 8. Install & configure pre-commit hooks

**Why it’s important**  
Pre-commit automates running linters and formatters before each commit, enforcing code style and catching errors early in the workflow.

**What’s going on**  
```bash
pip install --upgrade pre-commit black isort flake8
sed -i '' 's|https://gitlab.com/PyCQA/flake8|https://github.com/PyCQA/flake8|g' .pre-commit-config.yaml
pre-commit autoupdate
pre-commit install --install-hooks
```
1. Installs the hook runner and tools:  
   - **black** (code formatter)  
   - **isort** (import sorter)  
   - **flake8** (style checker)  
2. Uses `sed` to switch Flake8’s repo URL to GitHub (avoids GitLab auth prompts).  
3. `autoupdate` pins each hook to a fixed latest version.  
4. `install --install-hooks` writes the hook scripts into `.git/hooks`.

---

## 9. Install JupyterLab, LSP & register the kernel

**Why it’s important**  
JupyterLab provides an interactive notebook environment; the Language Server Protocol (LSP) adds code intelligence; registering your project venv as a kernel ensures notebooks use the same dependencies.

**What’s going on**  
```bash
pip install jupyterlab jupyterlab-lsp notebook-shim ipykernel
python -m ipykernel install --user --name=my-project-venv --display-name "Python (my-project-venv)"
```
- Installs JupyterLab and required extensions.  
- Registers your virtual environment under a friendly name so it appears in the kernel list.

---

🎉 **Next Steps**  
1. Restart your terminal to apply all shell configuration changes.  
2. Open your editor (e.g. VS Code), select the new interpreter, and start coding!

