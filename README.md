

### Hook Setup

Because the .git-Directory is not tracked by Git,
the Hooks are stored in the git_hooks-Directory.
Beacuse of this additional Setup is required:

```
git config core.hooksPath git_hooks/
```

On Linux:
```
chmod 777 git_hooks/pre-commit
```
