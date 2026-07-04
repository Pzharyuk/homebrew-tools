class LiveTranslatorAgent < Formula
  desc "Browserless mic streaming agent for Live Translator"
  homepage "https://github.com/Pzharyuk/live-translator-agent"
  url "https://github.com/Pzharyuk/live-translator-agent/archive/refs/tags/v1.4.3.tar.gz"
  sha256 "3168951fd1cf91c6712999c5c9a35e7c45bcce4c8817c2cb4875437d0f51d182"
  license "MIT"

  depends_on "node"
  depends_on "sox"

  def install
    system "npm", "install", "--production"
    libexec.install Dir["*"]
    (bin/"live-translator-agent").write <<~EOS
      #!/bin/bash
      # launchd runs services with a minimal PATH; export HOMEBREW_PREFIX/bin so
      # the child `sox` process spawned by node-record-lpcm16 is resolvable.
      export PATH="#{HOMEBREW_PREFIX}/bin:$PATH"
      exec "#{Formula["node"].opt_bin}/node" "#{libexec}/daemon.js" "$@"
    EOS
  end

  service do
    run [opt_bin/"live-translator-agent"]
    keep_alive true
    log_path var/"log/live-translator-agent.log"
    error_log_path var/"log/live-translator-agent.log"
  end

  def post_install
    # macOS launchd-spawned processes don't get the standard Microphone
    # permission prompt — sox is silently killed by TCC until the sox
    # binary itself is added to System Settings → Privacy & Security →
    # Microphone. Surface the requirement immediately on install so
    # users don't hit a confusing "Audio stream error" hours later.
    # Non-fatal: any failure (headless CI, brew-in-container, dismissed
    # dialog) is swallowed so install completes regardless.
    return unless OS.mac?

    sox_path = HOMEBREW_PREFIX/"bin/sox"

    dialog = <<~OSA
            try
              display dialog ¬
                "live-translator-agent v#{version} installed.

      To stream microphone audio, macOS requires you to grant Microphone permission to the sox binary directly — Terminal's grant does NOT cascade to launchd-spawned processes.

      Click 'Open Microphone Settings' below, then:

        1. Click the '+' button (unlock if prompted)
        2. Press  Cmd+Shift+G  in the file picker
        3. Paste:  #{sox_path}
        4. Click Open, then toggle the new entry ON

      After that:
        brew services start live-translator-agent" ¬
                buttons {"Skip", "Open Microphone Settings"} ¬
                default button 2 ¬
                with title "Live Translator Agent setup" ¬
                with icon note
              if button returned of result is "Open Microphone Settings" then
                do shell script "open 'x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone'"
              end if
            on error
              -- User dismissed or osascript unavailable; non-fatal.
            end try
    OSA
    system "osascript", "-e", dialog
  end

  def caveats
    sox_path = HOMEBREW_PREFIX/"bin/sox"
    <<~EOS
      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      REQUIRED — macOS Microphone permission (one-time, per Mac)
      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

      Because the agent runs under `launchd`, macOS will silently kill
      sox the first time it tries to open the microphone unless the sox
      binary itself is added to the Microphone privacy list.

      The install dialog should have opened System Settings for you.
      If you missed it, re-run the helper:

        live-translator-agent --grant-mic

      …or open System Settings manually:
        System Settings → Privacy & Security → Microphone
        Click "+" → Cmd+Shift+G → paste:  #{sox_path}
        Open → toggle ON

      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

      Config file (create before starting the service):

        mkdir -p ~/.config/live-translator-agent
        cat > ~/.config/live-translator-agent/config.json << 'EOF'
        {
          "serverUrl": "https://translate.onit.systems",
          "label": "My Mac",
          "agentPsk": "paste-the-server-PSK-here"
        }
        EOF
        chmod 600 ~/.config/live-translator-agent/config.json

      The server rejects agents whose `agentPsk` does not match its
      configured `auth.agent_psk` (the AGENT_PSK env var on the backend).
      Ask your server admin for the value. The AGENT_PSK environment
      variable, if set, overrides the config field.

      Start the agent:
        brew services start live-translator-agent

      To stream from a specific mic, pick the device in the
      live-translator admin UI's Remote Audio Sources panel.
    EOS
  end
end
