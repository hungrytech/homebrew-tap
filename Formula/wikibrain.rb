class Wikibrain < Formula
  include Language::Python::Virtualenv

  desc "Local-first personal memory bridge for Claude Code and Codex"
  homepage "https://github.com/hungrytech/wikibrain"
  url "https://github.com/hungrytech/wikibrain/archive/refs/tags/v0.1.3.tar.gz"
  sha256 "cba9f5c63047712a0ae1e7bb63d01c6ce1353fb08d9ae041eadf1c879ecaab1b"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/hungrytech/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "8142ca6227dfdbd1bc0aa680230206537227348ceb768fd53f37ac9d638bfb61"
    sha256 cellar: :any_skip_relocation, sequoia:      "8d9456272751bc634b451404b73efcc97ac40548a247e51930c48eef5a214e80"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "fff661305916c102dc2bc353bb31a8df02e0d8523a49f1b86830a0e92ff0f12b"
  end

  depends_on "python@3.13"

  resource "setuptools" do
    url "https://files.pythonhosted.org/packages/5d/40/e1e72872c6354b306daef1703549e8e83b4d43cfea356311bf722a043752/setuptools-83.0.0-py3-none-any.whl"
    sha256 "29b23c360f22f414dc7336bb39178cc7bcbf6021ed2733cde173f09dba19abb3"
  end

  resource "wikimap" do
    url "https://files.pythonhosted.org/packages/e6/78/02b369cddd288f009f43706a9219695e37aa772bb9856e2090fb5eacc1f9/wikimap-1.1.0.tar.gz"
    sha256 "75d5bfa358b8b924c05c58b41744eb699c3fbf7bbab852ad60ea3dd95b07c781"
  end

  def install
    # Both projects use setuptools as their PEP 517 backend. Install the
    # pinned backend first, then disable isolated network resolution.
    venv = virtualenv_create(libexec, "python3.13")
    venv.pip_install resource("setuptools"), build_isolation: false
    venv.pip_install_and_link resource("wikimap"), build_isolation: false
    venv.pip_install_and_link buildpath, build_isolation: false
  end

  def caveats
    <<~EOS
      WikiBrain does not edit agent settings during brew install.
      Initialize the private vault and install reviewed hooks explicitly:

        brainctl init
        brainctl doctor

      The default workspace root is your home directory. Use one or more
      --workspace PATH options when you want a narrower capture allowlist.

      Codex manual recall and remember commands work immediately. Automatic
      Codex capture and recall require a new session plus /hooks review of the
      current definition hash. brainctl does not inspect or bypass that trust.

      After a future brew upgrade, refresh the managed shim and skills with:

        brainctl setup
        brainctl doctor

      Personal data lives outside the Homebrew Cellar and is preserved by
      brew uninstall. Remove hooks and generated skills first with:

        brainctl hooks uninstall
        brainctl skills uninstall
    EOS
  end

  test do
    ENV["WIKIBRAIN_HOME"] = testpath/"brain"
    ENV["HOME"] = testpath/"user-home"
    ENV.prepend_path "PATH", bin
    (testpath/"user-home").mkpath

    assert_match "brainctl 0.1.3", shell_output("#{bin}/brainctl --version")
    assert_match "wikimap 1.1.0", shell_output("#{bin}/wikimap --version")

    system bin/"brainctl", "init", "--no-hooks", "--no-skills"
    assert_path_exists testpath/"brain/config.json"
    assert_match (testpath/"user-home").to_s,
                 (testpath/"brain/config.json").read

    doctor = shell_output("#{bin}/brainctl doctor --skip-hooks --json")
    assert_match '"initialized": true', doctor
    assert_match '"status": "ok"', doctor
  end
end
