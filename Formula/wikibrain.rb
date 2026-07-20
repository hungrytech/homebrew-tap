class Wikibrain < Formula
  include Language::Python::Virtualenv

  desc "Local-first personal memory bridge for Claude Code and Codex"
  homepage "https://github.com/hungrytech/wikibrain"
  url "https://github.com/hungrytech/wikibrain/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "b201b374b3914373cc3e24a8750337b7990ca80f4c78384389bebccba8fa3ad5"
  license "MIT"
  revision 1

  bottle do
    root_url "https://ghcr.io/v2/hungrytech/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "2f7971d86524caf80546fb930e1154896317cd53f14bac70a3f87f0b6069f54b"
    sha256 cellar: :any_skip_relocation, sequoia:      "6cdd74aa02b568aa7cc3cf56d5944a39081a676deec3e4d4eeacc4fab4a7b1f6"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "87fea6e1a40b272be8e7e828377963bba9ec4fc0e24ae2131e3c4a6218aa3b79"
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

        brainctl init --workspace /path/to/project
        brainctl doctor

      Codex users must start a new session, open /hooks, and trust the
      reviewed WikiBrain definitions.

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
    ENV.prepend_path "PATH", bin

    assert_match "brainctl 0.1.0", shell_output("#{bin}/brainctl --version")
    assert_match "wikimap 1.1.0", shell_output("#{bin}/wikimap --version")

    system bin/"brainctl", "init",
           "--no-hooks", "--no-skills", "--workspace", testpath.to_s
    assert_path_exists testpath/"brain/config.json"

    doctor = shell_output("#{bin}/brainctl doctor --skip-hooks --json")
    assert_match '"initialized": true', doctor
    assert_match '"status": "ok"', doctor
  end
end
