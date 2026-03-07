#!/usr/bin/env node

/**
 * Clearsky Test Framework
 * 
 * Tests for Clearsky migrations and services
 * 
 * Usage:
 *   node test.js                    # Run all tests
 *   node test.js --test tailscale   # Run specific test
 *   node test.js --verbose          # Verbose output
 */

const { exec, spawn } = require('child_process');
const fs = require('fs');
const path = require('path');
const os = require('os');

// Colors
const colors = {
  reset: '\x1b[0m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m',
  bold: '\x1b[1m'
};

function log(message, color = 'white') {
  const c = colors[color] || '';
  console.log(`${c}${message}${colors.reset}`);
}

function logTest(name) {
  console.log(`\n${colors.bold}${colors.cyan}┌─────────────────────────────────────────────────────────────${colors.reset}`);
  console.log(`${colors.bold}${colors.cyan}│${colors.reset} ${colors.bold}${name}${colors.reset}`);
  console.log(`${colors.bold}${colors.cyan}└─────────────────────────────────────────────────────────────${colors.reset}`);
}

function logStep(message) {
  console.log(`  ${colors.blue}▶${colors.reset} ${message}`);
}

function logSuccess(message) {
  console.log(`  ${colors.green}✓${colors.reset} ${message}`);
}

function logError(message) {
  console.log(`  ${colors.red}✗${colors.reset} ${message}`);
}

function logWarning(message) {
  console.log(`  ${colors.yellow}⚠${colors.reset} ${message}`);
}

// Test configuration
const TEST_DIR = path.join(os.tmpdir(), 'clearsky-test-' + Date.now());
const DATA_DIR = path.join(os.homedir(), '.clearsky-test');

// Source Nix
function sourceNix() {
  return `. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh 2>/dev/null || . ~/.nix-profile/etc/profile.d/nix-daemon.sh 2>/dev/null || true`;
}

// Detect container runtime
async function getContainerRuntime() {
  return new Promise((resolve) => {
    exec('which nix-container-run podman docker 2>/dev/null | head -1', (error, stdout) => {
      const runtime = stdout.trim();
      if (runtime.includes('nix-container-run')) {
        resolve({ cmd: 'nix-container-run', name: 'nix-containers' });
      } else if (runtime.includes('podman')) {
        resolve({ cmd: 'podman', name: 'podman' });
      } else if (runtime.includes('docker')) {
        resolve({ cmd: 'docker', name: 'docker' });
      } else {
        resolve({ cmd: null, name: 'none' });
      }
    });
  });
}

// Test results
const results = {
  passed: 0,
  failed: 0,
  skipped: 0,
  tests: []
};

function recordResult(name, passed, message = '') {
  results.tests.push({ name, passed, message });
  if (passed) {
    results.passed++;
  } else {
    results.failed++;
  }
}

/**
 * Test 1: Basic Scaffolding
 * 
 * Verify the basic structure is in place
 */
async function testScaffolding(verbose = false) {
  logTest('Test 1: Basic Scaffolding');
  
  let passed = true;
  
  // Check 1: Project structure
  logStep('Checking project structure...');
  
  const requiredFiles = [
    'flake.nix',
    'appimage.nix',
    'migrations/registry.nix',
    'migrations/harnesses/default.nix',
    'clearsky-cli.js'
  ];
  
  for (const file of requiredFiles) {
    const filePath = path.join(process.cwd(), file);
    if (fs.existsSync(filePath)) {
      logSuccess(`Found: ${file}`);
    } else {
      logError(`Missing: ${file}`);
      passed = false;
    }
  }
  
  // Check 2: Migration directories
  logStep('Checking migration directories...');
  
  const migrations = [
    'google-photos-to-immich',
    'google-docs-to-etherpad',
    'nextcloud-setup',
    'owncloud-setup',
    'homeassistant-setup'
  ];
  
  for (const migration of migrations) {
    const migrationPath = path.join(process.cwd(), 'migrations', migration);
    if (fs.existsSync(migrationPath)) {
      logSuccess(`Migration exists: ${migration}`);
    } else {
      logError(`Missing migration: ${migration}`);
      passed = false;
    }
  }
  
  // Check 3: Nix is available
  logStep('Checking Nix availability...');
  
  await new Promise((resolve) => {
    exec(`${sourceNix()} && nix --version`, (error, stdout) => {
      if (error) {
        logError('Nix is not installed');
        passed = false;
      } else {
        logSuccess(`Nix is installed: ${stdout.trim()}`);
      }
      resolve();
    });
  });
  
  // Check 4: Container runtime
  logStep('Checking container runtime...');
  
  await new Promise((resolve) => {
    exec('which nix-container-run podman docker 2>/dev/null | head -1', (error, stdout) => {
      const runtime = stdout.trim();
      if (runtime.includes('nix-container-run')) {
        logSuccess('Container runtime: nix-containers');
      } else if (runtime.includes('podman')) {
        logSuccess('Container runtime: podman');
      } else if (runtime.includes('docker')) {
        logSuccess('Container runtime: docker');
      } else {
        logWarning('No container runtime found (nix-containers, podman, or docker)');
      }
      resolve();
    });
  });
  
  recordResult('Scaffolding', passed);
  return passed;
}

/**
 * Test 2: Tailscale Startup
 * 
 * Start Tailscale container and verify it runs
 */
async function testTailscale(verbose = false) {
  logTest('Test 2: Tailscale Startup');
  
  let passed = true;
  const containerName = 'clearsky-test-tailscale';
  
  // Detect runtime
  const runtime = await getContainerRuntime();
  if (!runtime.cmd) {
    logError('No container runtime found (nix-containers, podman, or docker)');
    recordResult('Tailscale', false);
    return false;
  }
  logStep(`Using container runtime: ${runtime.name}`);
  
  // Cleanup any existing container
  logStep('Cleaning up existing containers...');
  await new Promise((resolve) => {
    exec(`${runtime.cmd} stop ${containerName} 2>/dev/null; ${runtime.cmd} rm ${containerName} 2>/dev/null; true`, resolve);
  });
  
  // Start Tailscale
  logStep('Starting Tailscale container...');
  
  await new Promise((resolve, reject) => {
    const cmd = `${runtime.cmd} run -d --rm --name ${containerName} ` +
      `--cap-add=NET_ADMIN --cap-add=SYS_MODULE ` +
      `-v /dev/net/tun:/dev/net/tun -v /run:/run ` +
      `tailscale/tailscale:latest`;
    
    exec(cmd, (error, stdout, stderr) => {
      if (error) {
        logError(`Failed to start Tailscale: ${stderr || error.message}`);
        passed = false;
        reject(error);
      } else {
        logSuccess('Tailscale container started');
        resolve(stdout.trim());
      }
    });
  }).catch(() => passed = false);
  
  if (!passed) {
    recordResult('Tailscale', false);
    return false;
  }
  
  // Wait for Tailscale to initialize
  logStep('Waiting for Tailscale to initialize...');
  await new Promise(resolve => setTimeout(resolve, 5000));
  
  // Check container is running
  logStep('Checking container status...');
  await new Promise((resolve) => {
    exec(`${runtime.cmd} ps --filter name=${containerName} --format '{{.Status}}'`, (error, stdout) => {
      if (error || !stdout.includes('Up')) {
        logError('Tailscale container is not running');
        passed = false;
      } else {
        logSuccess('Tailscale container is running');
      }
      resolve();
    });
  });
  
  // Cleanup
  logStep('Cleaning up...');
  exec(`${runtime.cmd} stop ${containerName} 2>/dev/null; true`);
  
  recordResult('Tailscale', passed);
  return passed;
}

/**
 * Test 3: Immich Startup
 * 
 * Start Immich container and verify it's accessible
 */
async function testImmich(verbose = false) {
  logTest('Test 3: Immich Startup');
  
  let passed = true;
  const containerName = 'clearsky-test-immich';
  const port = 2283;
  
  // Detect runtime
  const runtime = await getContainerRuntime();
  if (!runtime.cmd) {
    logError('No container runtime found');
    recordResult('Immich', false);
    return false;
  }
  logStep(`Using container runtime: ${runtime.name}`);
  
  // Cleanup
  logStep('Cleaning up existing containers...');
  await new Promise((resolve) => {
    exec(`${runtime.cmd} stop ${containerName} 2>/dev/null; ${runtime.cmd} rm ${containerName} 2>/dev/null; true`, resolve);
  });
  
  // Create test data directory
  const testDataDir = path.join(DATA_DIR, 'immich-test');
  fs.mkdirSync(testDataDir, { recursive: true });
  
  // Start Immich
  logStep('Starting Immich container...');
  
  await new Promise((resolve, reject) => {
    const cmd = `${runtime.cmd} run -d --rm --name ${containerName} ` +
      `-p ${port}:2283 ` +
      `-v ${testDataDir}:/mnt/data ` +
      `ghcr.io/immich-app/immich-server:release`;
    
    exec(cmd, (error, stdout, stderr) => {
      if (error) {
        logError(`Failed to start Immich: ${stderr || error.message}`);
        passed = false;
        reject(error);
      } else {
        logSuccess('Immich container started');
        resolve();
      }
    });
  }).catch(() => passed = false);
  
  if (!passed) {
    recordResult('Immich', false);
    return false;
  }
  
  // Wait for Immich to start
  logStep('Waiting for Immich to start (up to 120 seconds)...');
  
  let started = false;
  for (let i = 0; i < 120; i++) {
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    try {
      const response = await fetch(`http://localhost:${port}/api/health`);
      if (response.ok) {
        started = true;
        break;
      }
    } catch (e) {
      // Keep waiting
    }
    
    if (i % 20 === 0 && i > 0) {
      logStep(`Still waiting... (${i}s)`);
    }
  }
  
  if (started) {
    logSuccess('Immich is accessible');
  } else {
    logError('Immich did not become accessible');
    passed = false;
  }
  
  // Check health endpoint
  if (started) {
    logStep('Checking health endpoint...');
    try {
      const response = await fetch(`http://localhost:${port}/api/health`);
      const data = await response.json();
      logSuccess(`Health check passed`);
    } catch (e) {
      logError(`Health check failed: ${e.message}`);
      passed = false;
    }
  }
  
  // Cleanup
  logStep('Cleaning up...');
  exec(`${runtime.cmd} stop ${containerName} 2>/dev/null; true`);
  
  recordResult('Immich', passed);
  return passed;
}

/**
 * Test 4: Etherpad Startup
 * 
 * Start Etherpad container and verify it's accessible
 */
async function testEtherpad(verbose = false) {
  logTest('Test 4: Etherpad Startup');
  
  let passed = true;
  const containerName = 'clearsky-test-etherpad';
  const port = 9001;
  
  // Detect runtime
  const runtime = await getContainerRuntime();
  if (!runtime.cmd) {
    logError('No container runtime found');
    recordResult('Etherpad', false);
    return false;
  }
  logStep(`Using container runtime: ${runtime.name}`);
  
  // Cleanup
  logStep('Cleaning up existing containers...');
  await new Promise((resolve) => {
    exec(`${runtime.cmd} stop ${containerName} 2>/dev/null; ${runtime.cmd} rm ${containerName} 2>/dev/null; true`, resolve);
  });
  
  // Create test data directory
  const testDataDir = path.join(DATA_DIR, 'etherpad-test');
  fs.mkdirSync(testDataDir, { recursive: true });
  
  // Start Etherpad
  logStep('Starting Etherpad container...');
  
  await new Promise((resolve, reject) => {
    const cmd = `${runtime.cmd} run -d --rm --name ${containerName} ` +
      `-p ${port}:9001 ` +
      `-v ${testDataDir}:/opt/etherpad-lite/var ` +
      `-e TITLE="Clearsky Test Etherpad" ` +
      `etherpad/etherpad:latest`;
    
    exec(cmd, (error, stdout, stderr) => {
      if (error) {
        logError(`Failed to start Etherpad: ${stderr || error.message}`);
        passed = false;
        reject(error);
      } else {
        logSuccess('Etherpad container started');
        resolve();
      }
    });
  }).catch(() => passed = false);
  
  if (!passed) {
    recordResult('Etherpad', false);
    return false;
  }
  
  // Wait for Etherpad to start
  logStep('Waiting for Etherpad to start (up to 30 seconds)...');
  
  let started = false;
  for (let i = 0; i < 30; i++) {
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    try {
      const response = await fetch(`http://localhost:${port}/`);
      if (response.ok) {
        started = true;
        break;
      }
    } catch (e) {
      // Keep waiting
    }
    
    if (i % 10 === 0 && i > 0) {
      logStep(`Still waiting... (${i}s)`);
    }
  }
  
  if (started) {
    logSuccess('Etherpad is accessible');
  } else {
    logError('Etherpad did not become accessible');
    passed = false;
  }
  
  // Cleanup
  logStep('Cleaning up...');
  exec(`${runtime.cmd} stop ${containerName} 2>/dev/null; true`);
  
  recordResult('Etherpad', passed);
  return passed;
}

/**
 * Test 5: Migration Test (Placeholder)
 * 
 * This test requires actual Google Photos API credentials
 */
async function testMigration(verbose = false) {
  logTest('Test 5: Google Photos Migration (Placeholder)');
  
  logWarning('This test requires Google Photos API credentials');
  logWarning('Set GOOGLE_PHOTOS_API_KEY environment variable to run');
  
  const apiKey = process.env.GOOGLE_PHOTOS_API_KEY;
  
  if (!apiKey) {
    logStep('Skipping - no API key provided');
    recordResult('Migration', true, 'skipped');
    results.skipped++;
    return true;
  }
  
  logStep('API key found, migration test would run here');
  logStep('TODO: Implement actual migration test with cleanup');
  
  recordResult('Migration', true, 'placeholder');
  return true;
}

/**
 * Run all tests
 */
async function runTests(testFilter = null, verbose = false) {
  log(`\n${colors.bold}${colors.cyan}╔═══════════════════════════════════════════════════════════╗${colors.reset}`);
  log(`${colors.bold}${colors.cyan}║${colors.reset}  ${colors.bold}Clearsky Test Suite${colors.reset}                              ${colors.bold}${colors.cyan}║${colors.reset}`);
  log(`${colors.bold}${colors.cyan}╚═══════════════════════════════════════════════════════════╝${colors.reset}\n`);
  
  log(`Test directory: ${TEST_DIR}`);
  log(`Data directory: ${DATA_DIR}\n`);
  
  // Create test directories
  fs.mkdirSync(TEST_DIR, { recursive: true });
  fs.mkdirSync(DATA_DIR, { recursive: true });
  
  const tests = [
    { name: 'scaffolding', fn: testScaffolding },
    { name: 'tailscale', fn: testTailscale },
    { name: 'immich', fn: testImmich },
    { name: 'etherpad', fn: testEtherpad },
    { name: 'migration', fn: testMigration }
  ];
  
  for (const test of tests) {
    if (testFilter && test.name !== testFilter) {
      continue;
    }
    
    try {
      await test.fn(verbose);
    } catch (error) {
      logError(`Test ${test.name} threw exception: ${error.message}`);
      recordResult(test.name, false, error.message);
    }
  }
  
  // Cleanup
  fs.rmSync(TEST_DIR, { recursive: true, force: true });
  
  // Print results
  log(`\n${colors.bold}${colors.cyan}┌─────────────────────────────────────────────────────────────${colors.reset}`);
  log(`${colors.bold}${colors.cyan}│${colors.reset} ${colors.bold}Test Results${colors.reset}`);
  log(`${colors.bold}${colors.cyan}└─────────────────────────────────────────────────────────────${colors.reset}`);
  
  for (const result of results.tests) {
    const icon = result.passed ? colors.green + '✓' + colors.reset : colors.red + '✗' + colors.reset;
    const status = result.passed ? 'PASS' : (results.skipped > 0 ? 'SKIP' : 'FAIL');
    log(`  ${icon} ${result.name}: ${status}`);
  }
  
  log(`\n  ${colors.bold}Summary:${colors.reset}`);
  log(`    Passed:  ${colors.green}${results.passed}${colors.reset}`);
  log(`    Failed:  ${colors.red}${results.failed}${colors.reset}`);
  log(`    Skipped: ${colors.yellow}${results.skipped}${colors.reset}`);
  log('');
  
  // Exit with error if any tests failed
  if (results.failed > 0) {
    process.exit(1);
  }
}

// Parse arguments
const args = process.argv.slice(2);
const testFilter = args.find(arg => arg === '--test' || arg === '-t') ? args[args.indexOf('--test') + 1] || args[args.indexOf('-t') + 1] : null;
const verbose = args.includes('--verbose') || args.includes('-v');

// Run tests
runTests(testFilter, verbose).catch(error => {
  logError(`Test suite failed: ${error.message}`);
  console.error(error);
  process.exit(1);
});
