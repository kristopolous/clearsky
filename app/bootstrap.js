const { execSync } = require('child_process');

/**
 * Simple bootstrap manager - detects available tools
 */
class Bootstrap {
  constructor() {
    this.platform = process.platform;
    this.runtime = this.detectRuntime();
    this.hasNix = this.checkCommand('nix');
  }

  /**
   * Check if a command exists
   */
  checkCommand(cmd) {
    try {
      execSync(`which ${cmd}`, { stdio: 'ignore' });
      return true;
    } catch (e) {
      return false;
    }
  }

  /**
   * Detect available container runtime
   * Priority: OrbStack > Podman > Docker
   */
  detectRuntime() {
    const runtimes = [
      { cmd: 'orb', name: 'orbstack' },
      { cmd: 'podman', name: 'podman' },
      { cmd: 'docker', name: 'docker' }
    ];

    for (const { cmd, name } of runtimes) {
      if (this.checkCommand(cmd)) {
        // Verify it's actually working
        try {
          execSync(`${cmd} --version`, { stdio: 'ignore' });
          return name;
        } catch (e) {}
      }
    }

    return null;
  }

  /**
   * Get install instructions for missing runtime
   */
  getInstallInstructions() {
    if (this.platform === 'darwin') {
      return {
        recommended: {
          name: 'OrbStack',
          cmd: 'brew install --cask orbstack',
          url: 'https://orbstack.dev',
          note: 'Lightweight, macOS-native (recommended)'
        },
        alternative: {
          name: 'Docker Desktop',
          cmd: 'brew install --cask docker',
          url: 'https://docker.com',
          note: 'Most common option'
        }
      };
    }

    if (this.platform === 'linux') {
      return {
        recommended: {
          name: 'Podman',
          cmd: 'sudo apt install podman  # Ubuntu/Debian\nsudo dnf install podman  # Fedora',
          url: 'https://podman.io',
          note: 'Rootless, secure (recommended)'
        },
        alternative: {
          name: 'Docker',
          cmd: 'curl -fsSL https://get.docker.com | sh',
          url: 'https://docker.com',
          note: 'Most common option'
        }
      };
    }

    return null;
  }

  /**
   * Check if app is ready to run
   */
  isReady() {
    return {
      ready: this.runtime !== null,
      runtime: this.runtime,
      nix: this.hasNix,
      instructions: this.runtime ? null : this.getInstallInstructions()
    };
  }
}

module.exports = Bootstrap;
