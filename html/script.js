window.addEventListener('message', function (event) {
    let data = event.data || {};
    
    if (data.action === "updateMap") {
        document.getElementById('mapSelect').value = data.mapName;
    }

    if (data.action === "updateGameSettings") {
    
        document.getElementById('maxHealth').value = data.maxHealth;
        document.getElementById('maxArmor').value = data.maxArmor;
    
        if (data.healthRegen === true || data.healthRegen === "true") {
            document.getElementById('healthRegen').value = "true";
        } else {
            document.getElementById('healthRegen').value = "false";
        }
    
        document.getElementById('gameTimer').value = data.gameTimer;
        document.getElementById('scoreLimit').value = data.scoreLimit;
        document.getElementById('gameModeSelect').value = data.gameMode;
        document.getElementById('mapSelect').value = data.mapName;
        document.getElementById('weaponSelect').value = data.selectedWeapon;
        document.getElementById('carModel').value = data.carModel;
    
        const gameMode = data.gameMode;
        if (gameMode === "TDM") {
            document.getElementById('scoreLimitContainer').style.display = "block";
        } else {
            document.getElementById('scoreLimitContainer').style.display = "none";
        }
    
        if (gameMode === "HopOuts") {
            document.getElementById('carModelInput').style.display = "block";
            document.getElementById('infiltrateSettings').style.display = "none";
        } else if (gameMode === "Infiltrate") {
            document.getElementById('carModelInput').style.display = "none";
            document.getElementById('infiltrateSettings').style.display = "block";
            document.getElementById('defendingTeam').value = data.defendingTeam; 
        } else {
            document.getElementById('carModelInput').style.display = "none";
            document.getElementById('infiltrateSettings').style.display = "none";
        }
    }
    if (data.action === "openMenu") {
        document.getElementById("menu").style.display = "block";
        updateTeamLists(data.teams, data.MaxPlayersPerTeam);
        populateMapAndWeapons(data);
    }

    if (data.action === "updateTeams") {
        updateTeamLists(data.teams, data.MaxPlayersPerTeam);
    }
});

function joinTeam(team) {
    fetch(`https://${GetParentResourceName()}/joinTeam`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify({ team: team })
    }).then(response => {
        console.log(JSON.stringify(response)); 
    }).catch(err => {
        console.error("Error joining team:", err);
    });
}

function startGame() {
    const maxHealth = document.getElementById('maxHealth').value;
    const maxArmor = document.getElementById('maxArmor').value;
    const healthRegen = document.getElementById('healthRegen').value;
    const scoreLimit = document.getElementById('scoreLimit').value;
    const gameTimer = document.getElementById('gameTimer').value;
    const gameMode = document.getElementById('gameModeSelect').value;
    const selectedMap = document.getElementById('mapSelect').value;
    let carModel = null;
    let defendingTeam = null;

    let settings = {
        maxHealth,
        maxArmor,
        healthRegen,
        gameTimer,
        gameMode,
        mapName: selectedMap
    };

    if (gameMode === "TDM") {
        settings.scoreLimit = scoreLimit;
    } else if (gameMode === "HopOuts") {
        carModel = document.getElementById('carModel').value;
        settings.carModel = carModel;
    } else if (gameMode === "Infiltrate") {
        defendingTeam = document.getElementById('defendingTeam').value; 
        settings.defendingTeam = defendingTeam; 
    }

    fetch(`https://${GetParentResourceName()}/startGame`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(settings)
    }).then(() => {
        closeMenu();
    }).catch(err => {
        console.error("Error starting game:", err);
    });
}


function gatherAllSettings() {
    return {
        maxHealth: parseInt(document.getElementById('maxHealth').value) || 100,
        maxArmor: parseInt(document.getElementById('maxArmor').value) || 100,
        healthRegen: document.getElementById('healthRegen').value,
        scoreLimit: parseInt(document.getElementById('scoreLimit').value) || 10,
        gameTimer: parseInt(document.getElementById('gameTimer').value) || 50,
        gameMode: document.getElementById('gameModeSelect').value || 'TDM',
        mapName: document.getElementById('mapSelect').value || 'Map1',
        carModel: document.getElementById('carModel') ? document.getElementById('carModel').value : null,
        defendingTeam: document.getElementById('defendingTeam') ? document.getElementById('defendingTeam').value : null,
        selectedWeapon: document.getElementById('weaponSelect').value || null 
    };
}

function updateAllSettings() {
    const settings = gatherAllSettings();
    
    fetch(`https://${GetParentResourceName()}/updateSetting`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(settings)
    })
    .then(response => {
        if (!response.ok) {
            throw new Error('Failed to send setting update to server');
        }
    })
    .catch(err => {
        console.error("Error updating settings:", err);
    });
}

document.getElementById('maxHealth').addEventListener('change', updateAllSettings);
document.getElementById('maxArmor').addEventListener('change', updateAllSettings);
document.getElementById('healthRegen').addEventListener('change', updateAllSettings);
document.getElementById('gameModeSelect').addEventListener('change', updateAllSettings);
document.getElementById('scoreLimit').addEventListener('change', updateAllSettings);
document.getElementById('gameTimer').addEventListener('change', updateAllSettings);
document.getElementById('mapSelect').addEventListener('change', updateAllSettings);
document.getElementById('weaponSelect').addEventListener('change', updateAllSettings);


function updateTeamLists(teams, MaxPlayersPerTeam) {
    const redTeam = document.getElementById('redTeam');
    const blueTeam = document.getElementById('blueTeam');

    redTeam.innerHTML = '';
    blueTeam.innerHTML = '';

    for (let i = 0; i < MaxPlayersPerTeam; i++) {
        const listItem = document.createElement('li');
        if (teams.Red[i]) {
            listItem.textContent = teams.Red[i].name;
            listItem.classList.add('red');
        } else {
            listItem.textContent = 'Empty Slot';
            listItem.classList.add('empty');
        }
        redTeam.appendChild(listItem);
    }

    for (let i = 0; i < MaxPlayersPerTeam; i++) {
        const listItem = document.createElement('li');
        if (teams.Blue[i]) {
            listItem.textContent = teams.Blue[i].name;
            listItem.classList.add('blue');
        } else {
            listItem.textContent = 'Empty Slot';
            listItem.classList.add('empty');
        }
        blueTeam.appendChild(listItem);
    }
}

function populateMapAndWeapons(data) {
    const mapSelect = document.getElementById('mapSelect');
    mapSelect.innerHTML = '';  

    for (let map in data.maps) {
        if (data.maps.hasOwnProperty(map)) {
            const option = document.createElement('option');
            option.value = map;
            option.text = data.maps[map].MapName;
            mapSelect.add(option);
        }
    }

    const weaponSelect = document.getElementById('weaponSelect');
    weaponSelect.innerHTML = ''; 

    if (data.weapons && Array.isArray(data.weapons)) {
        data.weapons.forEach(weapon => {
            const option = document.createElement('option');
            option.value = weapon;
            option.text = weapon;
            weaponSelect.add(option);
        });

        if (data.selectedWeapon) {
            weaponSelect.value = data.selectedWeapon;
        }
    } else {
        console.error("Weapons data is missing or not an array.");
    }
}

function closeMenu() {
    document.getElementById("menu").style.display = "none";

    fetch(`https://${GetParentResourceName()}/closeMenu`, {  
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' }
    }).catch((err) => {
        console.error("Error closing menu:", err);
    });
}
