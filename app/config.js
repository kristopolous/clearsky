const fs = require('fs');
const path = require('path');
const os = require('os');

/**
 * Simple config loader - supports TOML and JSON
 * 
 * Priority:
 * 1. CLI args (not implemented here)
 * 2. Project config (./clearsky.toml)
 * 3. User config (~/.clearsky/config.toml)
 * 4. Defaults
 */

const DEFAULTS = {
  // Container runtime: 'auto', 'orbstack', 'podman', 'docker'
  runtime: 'auto',
  
  // Data directory
  dataDir: path.join(os.homedir(), '.clearsky'),
  
  // Service ports
  services: {
    immich: { port: 2283 },
    nextcloud: { port: 8080 },
    owncloud: { port: 8081 },
    homeassistant: { port: 8123 },
    ghost: { port: 2368 },
    etherpad: { port: 9001 }
  },
  
  // Migration source: 'auto', 'nix', 'shell'
  migrations: {
    source: 'auto'
  },
  
  // Container options
  containers: {
    extraArgs: []
  }
};

class Config {
  constructor() {
    this.config = this.load();
  }

  /**
   * Load config from files
   */
  load() {
    let config = { ...DEFAULTS };

    // Load user config
    const userConfigPath = path.join(os.homedir(), '.clearsky', 'config.toml');
    const userConfig = this.loadFile(userConfigPath);
    if (userConfig) {
      config = this.merge(config, userConfig);
      console.log(`Loaded user config: ${userConfigPath}`);
    }

    // Load project config
    const projectConfigPath = path.join(process.cwd(), 'clearsky.toml');
    const projectConfig = this.loadFile(projectConfigPath);
    if (projectConfig) {
      config = this.merge(config, projectConfig);
      console.log(`Loaded project config: ${projectConfigPath}`);
    }

    return config;
  }

  /**
   * Load config file (TOML or JSON)
   */
  loadFile(filePath) {
    if (!fs.existsSync(filePath)) {
      return null;
    }

    try {
      const content = fs.readFileSync(filePath, 'utf-8');
      
      // Try TOML first
      if (filePath.endsWith('.toml')) {
        try {
          const toml = require('toml');
          return toml.parse(content);
        } catch (e) {
          console.warn(`Failed to parse TOML: ${e.message}`);
          return null;
        }
      }
      
      // Try JSON
      if (filePath.endsWith('.json')) {
        try {
          return JSON.parse(content);
        } catch (e) {
          console.warn(`Failed to parse JSON: ${e.message}`);
          return null;
        }
      }
      
      return null;
    } catch (e) {
      console.warn(`Failed to load config from ${filePath}: ${e.message}`);
      return null;
    }
  }

  /**
   * Deep merge configs
   */
  merge(target, source) {
    const result = { ...target };
    
    for (const key in source) {
      if (source[key] && typeof source[key] === 'object' && !Array.isArray(source[key])) {
        result[key] = this.merge(result[key] || {}, source[key]);
      } else {
        result[key] = source[key];
      }
    }
    
    return result;
  }

  /**
   * Get a config value
   */
  get(key, defaultValue) {
    const keys = key.split('.');
    let value = this.config;
    
    for (const k of keys) {
      if (value && value[k] !== undefined) {
        value = value[k];
      } else {
        return defaultValue;
      }
    }
    
    return value;
  }

  /**
   * Get all config
   */
  getAll() {
    return { ...this.config };
  }

  /**
   * Get runtime preference
   */
  getRuntime() {
    return this.get('runtime', 'auto');
  }

  /**
   * Get data directory
   */
  getDataDir() {
    const dir = this.get('dataDir', DEFAULTS.dataDir);
    // Expand ~
    if (dir.startsWith('~')) {
      return path.join(os.homedir(), dir.slice(1));
    }
    return dir;
  }

  /**
   * Get service port
   */
  getServicePort(serviceName) {
    return this.get(`services.${serviceName}.port`, DEFAULTS.services[serviceName]?.port);
  }
}

module.exports = Config;
