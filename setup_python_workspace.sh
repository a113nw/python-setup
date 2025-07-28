#!/usr/bin/env bash
set -euo pipefail

#  Run this from your project’s root directory.

echo "=== 1. Install Homebrew if missing ==="
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "Homebrew already installed."
fi

echo "=== 2. Install required packages via Homebrew ==="
brew install git pyenv pyenv-virtualenv node

echo "=== 3. Configure pyenv in your shell ==="
# ~/.zprofile for login shells
if ! grep -q "pyenv init --path" ~/.zprofile 2>/dev/null; then
  cat << 'EOF' >> ~/.zprofile

# pyenv initialization (login shells)
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init --path)"
fi
EOF
  echo "Appended pyenv init to ~/.zprofile"
fi

# ~/.zshrc for interactive shells
if ! grep -q "pyenv virtualenv-init" ~/.zshrc 2>/dev/null; then
  cat << 'EOF' >> ~/.zshrc

# pyenv shims & pyenv-virtualenv (interactive shells)
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi
EOF
  echo "Appended pyenv-virtualenv init to ~/.zshrc"
fi

echo "Reloading your shell..."
exec "$SHELL" -l

echo "=== 4. Install Python 3.11.5 & create a virtualenv ==="
pyenv install -s 3.11.5
pyenv virtualenv -f 3.11.5 my-project-venv
pyenv local my-project-venv

echo "=== 5. Install Poetry ==="
if ! command -v poetry >/dev/null 2>&1; then
  curl -sSL https://install.python-poetry.org | python3 -
  export PATH="$HOME/.local/bin:$PATH"
fi

echo "=== 6. Re-enable 'poetry shell' if you like it ==="
poetry self add poetry-plugin-shell || true

echo "=== 7. Make sure this is a Git repo ==="
if [ ! -d .git ]; then
  git init
  git add .
  git commit -m "Initial commit for pre-commit"
  echo "Initialized Git repo and made first commit."
fi

echo "=== 8. Install & configure pre-commit hooks ==="
pip install --upgrade pre-commit black isort flake8
if [ -f .pre-commit-config.yaml ]; then
  # fix the Flake8 repo URL (avoid GitLab auth error)
  sed -i '' 's|https://gitlab.com/PyCQA/flake8|https://github.com/PyCQA/flake8|g' .pre-commit-config.yaml
  pre-commit autoupdate
  pre-commit install --install-hooks
  echo "pre-commit hooks installed and updated."
else
  echo "⚠️  .pre-commit-config.yaml not found — skipped hook installation."
fi

echo "=== 9. Install JupyterLab, LSP & kernel ==="
pip install jupyterlab jupyterlab-lsp notebook-shim ipykernel
python -m ipykernel install --user --name=my-project-venv --display-name "Python (my-project-venv)"

echo
echo "🎉  Setup complete! Please restart your terminal to apply all changes."
