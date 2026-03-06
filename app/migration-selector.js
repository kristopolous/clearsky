// Migration selector UI
const migrationSelector = document.createElement('div');
migrationSelector.innerHTML = `
  <div class="info-box">
    <h3>Select Migration</h3>
    <p>Choose a migration strategy to use:</p>
    <select id="migration-select" style="padding: 10px; font-size: 1rem; width: 100%; margin-top: 10px;">
      <option value="">Loading migrations...</option>
    </select>
    <div id="migration-description" style="margin-top: 10px; color: #666;"></div>
  </div>
`;

// Inject migration selector into welcome screen
const welcomeScreen = document.getElementById('step-welcome');
if (welcomeScreen) {
  const selectionPoint = welcomeScreen.querySelector('.checkbox-group');
  if (selectionPoint) {
    selectionPoint.parentNode.insertBefore(migrationSelector, selectionPoint);
  }
}

// Load migrations
async function loadMigrations() {
  try {
    const response = await fetch('http://localhost:8080/migrations');
    const migrations = await response.json();
    
    const select = document.getElementById('migration-select');
    select.innerHTML = '<option value="">Select a migration...</option>';
    
    Object.entries(migrations).forEach(([name, migration]) => {
      const option = document.createElement('option');
      option.value = name;
      option.textContent = `${migration.name} (${migration.source} → ${migration.target})`;
      select.appendChild(option);
    });
    
    // Update description when selection changes
    select.addEventListener('change', (e) => {
      const migration = migrations[e.target.value];
      if (migration) {
        document.getElementById('migration-description').textContent = migration.description;
      }
    });
  } catch (error) {
    console.log('Could not load migrations:', error);
    // Fallback to hardcoded migration
    const select = document.getElementById('migration-select');
    select.innerHTML = `
      <option value="google-photos-to-immich">Google Photos to Immich</option>
      <option value="icloud-to-immich">iCloud Photos to Immich</option>
    `;
  }
}

// Initialize migration selector
loadMigrations();