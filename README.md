# homebrew-tools

Paul's personal Homebrew tap.

## Installation

```sh
brew tap Pzharyuk/tools
```

## Formulae

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
