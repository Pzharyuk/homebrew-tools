# homebrew-tools

Paul's personal Homebrew tap.

## Installation

```sh
brew tap Pzharyuk/tools
```

## Formulae

### harness-memory

CLI (`memory`) and daemon (`memoryd`) for [harness-memory](https://github.com/Pzharyuk/harness-memory) — shared Postgres memory for Claude, Grok, and other agents.

```sh
brew tap Pzharyuk/tools
brew install harness-memory
```

**Local brain**

```sh
brew services start postgresql@16
createdb memory
brew services start harness-memory
memory init
memory token create --harness claude
```

**Cluster brain** (do not start local Postgres or the service):

```sh
export MEMORY_URL=https://memory.onit.systems
memory init
memory token create --harness grok
```

Must be on the church office IP. Docs: [install](https://github.com/Pzharyuk/harness-memory/blob/main/docs/install.md), [usage](https://github.com/Pzharyuk/harness-memory/blob/main/docs/usage.md).

**Dependencies:** `go` (build), `postgresql@16`

### live-translator-agent

Browserless macOS mic daemon for [live-translator-node](https://github.com/Pzharyuk/live-translator-node).
Captures microphone audio and streams it to your Live Translator backend via Socket.IO.

```sh
brew install live-translator-agent
```

**Setup:**

```sh
mkdir -p ~/.config/live-translator-agent
cat > ~/.config/live-translator-agent/config.json << 'EOF'
{
  "serverUrl": "https://translate.onit.systems",
  "label": "My Mac"
}
EOF

brew services start live-translator-agent
```

**Dependencies:** `node`, `sox`
