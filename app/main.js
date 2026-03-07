const { app, BrowserWindow, Tray, Menu, ipcMain, nativeImage } = require('electron');
const path = require('path');
const { exec, execSync } = require('child_process');
const fs = require('fs');

let mainWindow = null;
let tray = null;
const isDev = process.env.NODE_ENV === 'development';

// Load migrations from Nix registry
function loadMigrations() {
  try {
    // Try to load from Nix flake
    const projectRoot = path.join(__dirname, '..');
    const output = execSync(`cd ${projectRoot} && nix eval --json .#packages.x86_64-linux.default 2>/dev/null`, { encoding: 'utf-8' });
    return JSON.parse(output);
  } catch (error) {
    console.log('Warning: Could not load migrations from Nix, using fallback', error.message);
    // Fallback: return hardcoded migration info
    return {
      'google-photos-to-immich': {
        name: 'Google Photos to Immich',
        source: 'google-photos',
        target: 'immich',
        description: 'Migrate Google Photos exports to Immich',
        version: '1.0.0'
      }
    };
  }
}

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false
    },
    backgroundColor: '#87CEEB',
    icon: path.join(__dirname, 'assets', 'icon.png')
  });

  mainWindow.loadFile('index.html');

  mainWindow.on('closed', () => {
    mainWindow = null;
  });
}

function createTray() {
  const trayPath = path.join(__dirname, 'assets', 'icon.png');
  const trayIcon = nativeImage.createFromPath(trayPath);

  tray = new Tray(trayIcon);

  const contextMenu = Menu.buildFromTemplate([
    {
      label: 'Open Clearsky',
      click: () => {
        mainWindow.show();
      }
    },
    {
      label: 'Open Dashboard',
      click: () => {
        require('open')('http://localhost:2283');
      }
    },
    { type: 'separator' },
    {
      label: 'Quit',
      click: () => {
        app.quit();
      }
    }
  ]);

  tray.setContextMenu(contextMenu);
  tray.setIgnoreDoubleClickEvents(true);
  tray.on('click', () => {
    mainWindow.show();
  });
}

function checkPodmanInstalled() {
  return new Promise((resolve, reject) => {
    exec('podman --version', (error, stdout, stderr) => {
      if (error) {
        reject(new Error('Podman is not installed'));
        return;
      }
      resolve(stdout.trim());
    });
  });
}

async function startService(serviceName, port, image, env = {}) {
  return new Promise((resolve, reject) => {
    const containerName = `clearsky-${serviceName}`;
    const dataDir = path.join(process.env.HOME || process.env.HOMEPATH || process.env.USERPROFILE, '.clearsky', serviceName);

    fs.mkdirSync(dataDir, { recursive: true });

    const envArgs = Object.entries(env)
      .map(([key, value]) => `-e ${key}="${value}"`)
      .join(' ');

    const command = `podman run -d --rm --name ${containerName} -p ${port}:2283 ${envArgs} -v ${dataDir}:/mnt/data ${image}`;

    exec(command, (error, stdout, stderr) => {
      if (error) {
        reject(error);
        return;
      }
      resolve(stdout.trim());
    });
  });
}

async function stopService(serviceName) {
  return new Promise((resolve, reject) => {
    const containerName = `clearsky-${serviceName}`;
    exec(`podman stop ${containerName}`, (error, stdout, stderr) => {
      if (error) {
        reject(error);
        return;
      }
      resolve(stdout.trim());
    });
  });
}

async function importToImmich(zipPath) {
  return new Promise((resolve, reject) => {
    const command = `immich-go import --input "${zipPath}" --host http://localhost:2283 --key dummy`;
    exec(command, (error, stdout, stderr) => {
      if (error) {
        reject(error);
        return;
      }
      resolve(stdout.trim());
    });
  });
}

async function runMigration(migrationName, options = {}) {
  return new Promise((resolve, reject) => {
    try {
      // Get migration path
      const projectRoot = path.join(__dirname, '..');
      const migrationPath = path.join(projectRoot, 'migrations', migrationName);
      
      // Set up environment variables for the migration
      const env = { ...process.env };
      
      // Pass API key for Google Photos migration
      if (options.apiKey) {
        env.GOOGLE_PHOTOS_API_KEY = options.apiKey;
      }
      
      // Pass ZIP file path if provided
      if (options.files && options.files.length > 0) {
        env.GOOGLE_PHOTOS_ZIP = options.files[0];
      }

      // Try to build and run migration from Nix
      exec(`nix build ${migrationPath}#default -o /tmp/clearsky-migration 2>/dev/null`, (error) => {
        if (error) {
          // Fallback: check if migration script exists locally
          const scriptPath = path.join(migrationPath, 'bin', 'migrate');
          if (fs.existsSync(scriptPath)) {
            const child = exec(scriptPath, { env }, (err, stdout, stderr) => {
              if (err) {
                reject(err);
                return;
              }
              resolve(stdout.trim());
            });
            
            // Stream output to renderer
            child.stdout.on('data', (data) => {
              console.log(data.toString());
            });
            child.stderr.on('data', (data) => {
              console.error(data.toString());
            });
          } else {
            reject(new Error(`Migration ${migrationName} not found`));
          }
          return;
        }

        // Run the built migration with environment variables
        const child = exec('/tmp/clearsky-migration/bin/migrate', { env }, (err, stdout, stderr) => {
          if (err) {
            reject(err);
            return;
          }
          resolve(stdout.trim());
        });
        
        // Stream output to renderer
        child.stdout.on('data', (data) => {
          console.log(data.toString());
        });
        child.stderr.on('data', (data) => {
          console.error(data.toString());
        });
      });
    } catch (error) {
      reject(error);
    }
  });
}

app.on('ready', () => {
  createWindow();
  createTray();

  checkPodmanInstalled().catch(error => {
    if (mainWindow) {
      mainWindow.webContents.send('podman-missing', error.message);
    }
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', () => {
  if (mainWindow === null) {
    createWindow();
  }
});

ipcMain.on('check-podman', async (event) => {
  try {
    const version = await checkPodmanInstalled();
    event.sender.send('podman-status', { installed: true, version });
  } catch (error) {
    event.sender.send('podman-status', { installed: false, error: error.message });
  }
});

ipcMain.on('start-immich', async (event) => {
  try {
    const containerId = await startService('immich', 2283, 'ghcr.io/immich-app/immich-server:latest');
    event.sender.send('service-started', { service: 'immich', containerId });
  } catch (error) {
    event.sender.send('service-error', { service: 'immich', error: error.message });
  }
});

ipcMain.on('stop-immich', async (event) => {
  try {
    await stopService('immich');
    event.sender.send('service-stopped', { service: 'immich' });
  } catch (error) {
    event.sender.send('service-error', { service: 'immich', error: error.message });
  }
});

ipcMain.on('import-photos', async (event, zipPath) => {
  try {
    const result = await importToImmich(zipPath);
    event.sender.send('import-complete', { success: true, result });
  } catch (error) {
    event.sender.send('import-error', { error: error.message });
  }
});

ipcMain.on('start-tailscale', async (event, authKey) => {
  return new Promise((resolve, reject) => {
    const containerName = 'clearsky-tailscale';
    const command = authKey
      ? `podman run -d --rm --name ${containerName} --cap-add=NET_ADMIN --cap-add=SYS_MODULE -v /dev/net/tun:/dev/net/tun -v /run:/run ${authKey ? `-e TS_AUTHKEY="${authKey}"` : ''} tailscale/tailscale:latest tailnet --state-dir=/run/tailscale`
      : `podman run -d --rm --name ${containerName} --cap-add=NET_ADMIN --cap-add=SYS_MODULE -v /dev/net/tun:/dev/net/tun -v /run:/run tailscale/tailscale:latest tailnet --state-dir=/run/tailscale --no-verbose`;

    exec(command, (error, stdout, stderr) => {
      if (error) {
        reject(error);
        return;
      }
      resolve(stdout.trim());
    });
  });
});

ipcMain.on('rollback', async (event, serviceName) => {
  try {
    await stopService(serviceName);
    const dataDir = path.join(process.env.HOME || process.env.HOMEPATH || process.env.USERPROFILE, '.clearsky', serviceName);
    const backupDir = `${dataDir}.backup`;

    if (fs.existsSync(backupDir)) {
      fs.rmSync(dataDir, { recursive: true, force: true });
      fs.renameSync(backupDir, dataDir);
    }

    event.sender.send('rollback-complete', { service: serviceName, success: true });
  } catch (error) {
    event.sender.send('rollback-error', { service: serviceName, error: error.message });
  }
});

// IPC handlers for migrations
ipcMain.handle('get-migrations', async () => {
  return loadMigrations();
});

ipcMain.handle('run-migration', async (event, migrationName, options = {}) => {
  try {
    const result = await runMigration(migrationName, options);
    return { success: true, result };
  } catch (error) {
    return { success: false, error: error.message };
  }
});
