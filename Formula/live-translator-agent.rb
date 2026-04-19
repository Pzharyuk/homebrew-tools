class LiveTranslatorAgent < Formula
  desc "Browserless mic streaming agent for Live Translator"
  homepage "https://github.com/Pzharyuk/live-translator-agent"
  url "https://github.com/Pzharyuk/live-translator-agent/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "48c3438a8fd6508d7faa350f678d2f67129e993d1b1ad301544824254785490d"
  license "MIT"
  revision 1

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

  def caveats
    <<~EOS
      Create your config file before starting the service:

        mkdir -p ~/.config/live-translator-agent
        cat > ~/.config/live-translator-agent/config.json << 'EOF'
        {
          "serverUrl": "https://translate.onit.systems",
          "label": "My Mac"
        }
        EOF

      Then start the agent:
        brew services start live-translator-agent

      To stream from a non-default mic, add a "device" key to your config.json.
      Run `sox -d --list-devtypes` to list available audio devices.
    EOS
  end
end
