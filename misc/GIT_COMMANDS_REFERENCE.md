# Git Commands Reference

A comprehensive reference guide for commonly used Git commands.

---

## Basic Repository Operations

| Command | Description | Example |
|---------|-------------|---------|
| `git init` | Initialize a new Git repository | `git init` |
| `git clone <url>` | Clone a remote repository | `git clone https://github.com/user/repo.git` |
| `git status` | Show the working tree status | `git status` |

---

## Branching

| Command | Description | Example |
|---------|-------------|---------|
| `git branch` | List local branches | `git branch` |
| `git branch -a` | List all branches (local + remote) | `git branch -a` |
| `git branch <name>` | Create new branch | `git branch feature/new-feat` |
| `git branch -d <name>` | Delete merged branch | `git branch -d branch-name` |
| `git branch -D <name>` | Force delete branch | `git branch -D branch-name` |
| `git checkout <branch>` | Switch branches or restore files | `git checkout main` |
| `git checkout -b <branch>` | Create and switch to new branch | `git checkout -b feature/new-feat` |
| `git checkout -- <file>` | Discard changes in file | `git checkout -- file.txt` |
| `git switch <branch>` | Switch branches (newer command) | `git switch main` |
| `git switch -c <branch>` | Create and switch to new branch | `git switch -c feature/new-feat` |

---

## Making Changes

| Command | Description | Example |
|---------|-------------|---------|
| `git add <file>` | Stage specific file | `git add file.txt` |
| `git add .` | Stage all changes | `git add .` |
| `git add *.js` | Stage files matching pattern | `git add *.js` |
| `git add -A` | Stage all changes including deletions | `git add -A` |
| `git commit -m "<message>"` | Record changes with message | `git commit -m "Add new feature"` |
| `git commit -am "<message>"` | Add and commit in one step | `git commit -am "Quick commit"` |
| `git commit --amend` | Modify last commit | `git commit --amend` |
| `git restore <file>` | Discard changes in working directory | `git restore file.txt` |
| `git restore --staged <file>` | Unstage file | `git restore --staged file.txt` |

---

## Viewing History

| Command | Description | Example |
|---------|-------------|---------|
| `git log` | Show commit history | `git log` |
| `git log --oneline` | Compact one-line format | `git log --oneline` |
| `git log --graph --oneline` | Show with branch graph | `git log --graph --oneline` |
| `git log -n` | Show last n commits | `git log -5` |
| `git diff` | Show unstaged changes | `git diff` |
| `git diff --staged` | Show staged changes | `git diff --staged` |
| `git diff HEAD` | Show all changes | `git diff HEAD` |
| `git diff <commit1> <commit2>` | Compare two commits | `git diff commit1 commit2` |
| `git show` | Show last commit details | `git show` |
| `git show <commit-hash>` | Show specific commit | `git show abc123` |

---

## Remote Operations

| Command | Description | Example |
|---------|-------------|---------|
| `git remote -v` | List remotes | `git remote -v` |
| `git remote add <name> <url>` | Add remote repository | `git remote add origin <url>` |
| `git remote remove <name>` | Remove remote | `git remote remove origin` |
| `git fetch` | Download objects from default remote | `git fetch` |
| `git fetch <remote>` | Fetch from specific remote | `git fetch origin` |
| `git pull` | Fetch and merge from tracked branch | `git pull` |
| `git pull <remote> <branch>` | Pull specific branch | `git pull origin main` |
| `git push` | Push to tracked branch | `git push` |
| `git push <remote> <branch>` | Push to specific branch | `git push origin main` |
| `git push -u <remote> <branch>` | Push and set upstream | `git push -u origin branch` |
| `git push --delete <remote> <branch>` | Delete remote branch | `git push --delete origin branch` |

---

## Merging & Rebasing

| Command | Description | Example |
|---------|-------------|---------|
| `git merge <branch>` | Merge branch into current branch | `git merge feature-branch` |
| `git merge --no-ff <branch>` | Create merge commit even if fast-forward | `git merge --no-ff feature` |
| `git rebase <branch>` | Reapply commits on top of another base | `git rebase main` |
| `git rebase -i HEAD~n` | Interactive rebase of last n commits | `git rebase -i HEAD~3` |

---

## Stashing

| Command | Description | Example |
|---------|-------------|---------|
| `git stash` | Save changes temporarily | `git stash` |
| `git stash save "<message>"` | Stash with message | `git stash save "WIP: feature"` |
| `git stash list` | List all stashes | `git stash list` |
| `git stash pop` | Apply and remove most recent stash | `git stash pop` |
| `git stash apply` | Apply stash but keep it | `git stash apply` |
| `git stash drop` | Delete stash | `git stash drop` |

---

## Tagging

| Command | Description | Example |
|---------|-------------|---------|
| `git tag` | List tags | `git tag` |
| `git tag <name>` | Create lightweight tag | `git tag v1.0.0` |
| `git tag -a <name> -m "<message>"` | Create annotated tag | `git tag -a v1.0.0 -m "Release"` |
| `git push <remote> <tag>` | Push tag to remote | `git push origin v1.0.0` |

---

## Undoing Changes

| Command | Description | Example |
|---------|-------------|---------|
| `git reset --soft HEAD~n` | Undo commit, keep changes staged | `git reset --soft HEAD~1` |
| `git reset --mixed HEAD~n` | Undo commit, keep changes unstaged | `git reset --mixed HEAD~1` |
| `git reset --hard HEAD~n` | Undo commit and discard changes | `git reset --hard HEAD~1` |
| `git revert HEAD` | Create new commit that undoes last commit | `git revert HEAD` |
| `git revert <commit-hash>` | Revert specific commit | `git revert abc123` |

---

## Configuration

| Command | Description | Example |
|---------|-------------|---------|
| `git config --global user.name "<name>"` | Set global user name | `git config --global user.name "Your Name"` |
| `git config --global user.email "<email>"` | Set global user email | `git config --global user.email "email@example.com"` |
| `git config --list` | List all config settings | `git config --list` |

---

## Useful Aliases

You can create shortcuts for commonly used commands:

| Alias Setup | Description | Example |
|-------------|-------------|---------|
| `git config --global alias.st status` | Shortcut for status | `git st` |
| `git config --global alias.co checkout` | Shortcut for checkout | `git co` |
| `git config --global alias.br branch` | Shortcut for branch | `git br` |
| `git config --global alias.ci commit` | Shortcut for commit | `git ci` |

---

## Quick Reference

### Common Workflows

**Create feature branch and push:**
```bash
git checkout -b feature/new-feature
git add .
git commit -m "Add new feature"
git push -u origin feature/new-feature
```

**Update main branch:**
```bash
git checkout main
git pull origin main
```

**Merge feature branch:**
```bash
git checkout main
git merge feature/new-feature
git push origin main
```

**Delete merged branch:**
```bash
git branch -d feature/new-feature
git push origin --delete feature/new-feature
```

---

**Last Updated:** 2024




