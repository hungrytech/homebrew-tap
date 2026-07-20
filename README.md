# hungrytech Homebrew Tap

Homebrew formulae for [hungrytech](https://github.com/hungrytech) projects.

## WikiBrain

Install [WikiBrain](https://github.com/hungrytech/wikibrain):

```sh
brew install hungrytech/tap/wikibrain
```

Create the local brain and install reviewed Claude Code and Codex integrations:

```sh
brainctl init --workspace /path/to/project
brainctl doctor
```

WikiBrain does not change agent settings during `brew install`. The explicit
`brainctl init` step keeps hook installation reviewable and reversible.
