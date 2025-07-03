const express = require('express');
const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');
const http = require('http');

const app = express();
const server = http.createServer(app);
const PORT = process.env.PORT || 3000;

// Try to load WebSocket if available (for dashboard functionality)
let WebSocket = null;
let wss = null;
let dashboardClients = new Set();

try {
    WebSocket = require('ws');
    wss = new WebSocket.Server({ server });
    
    // WebSocket connection handler for dashboard
    wss.on('connection', (ws) => {
        console.log('📡 Dashboard client connected');
        dashboardClients.add(ws);
        
        ws.on('close', () => {
            console.log('📡 Dashboard client disconnected');
            dashboardClients.delete(ws);
        });
    });
    
    console.log('✅ WebSocket support enabled for dashboard');
} catch (error) {
    console.log('⚠️ WebSocket not available - dashboard will work in basic mode');
}

// Middleware
app.use(express.json());
app.use(express.static('.'));

// Store running processes
const runningProcesses = new Map();

// Broadcast to dashboard clients if WebSocket is available
function broadcastToDashboard(message) {
    if (dashboardClients && dashboardClients.size > 0) {
        const messageStr = JSON.stringify(message);
        dashboardClients.forEach(client => {
            if (client.readyState === WebSocket.OPEN) {
                client.send(messageStr);
            }
        });
    }
}

// Broadcast current status to all connected dashboard clients
function broadcastStatus() {
    const activeProcesses = Array.from(runningProcesses.keys());
    const v1Processes = activeProcesses.filter(key => key.startsWith('v1-'));
    const v2Processes = activeProcesses.filter(key => key.startsWith('v2-'));
    const v3Processes = activeProcesses.filter(key => key.startsWith('v3-'));
    
    broadcastToDashboard({
        type: 'status',
        data: {
            activeProcesses,
            v1Count: v1Processes.length,
            v2Count: v2Processes.length,
            v3Count: v3Processes.length,
            totalCount: activeProcesses.length,
            v1Processes,
            v2Processes,
            v3Processes
        }
    });
}

// API endpoint to start V2 automation
app.post('/api/start-automation-v2', async (req, res) => {
    try {
        const { deviceId, city } = req.body;
        
        if (!deviceId || !city) {
            return res.status(400).json({ error: 'Device ID and city are required' });
        }
        
        console.log(`🚀 Starting V2 automation for ${city} on device ${deviceId}`);
        
        // Kill any existing process for this device
        const processKey = `v2-${deviceId}-${city}`;
        if (runningProcesses.has(processKey)) {
            console.log('⚠️ Killing existing V2 process...');
            runningProcesses.get(processKey).kill();
            runningProcesses.delete(processKey);
        }
        
        // Path to the V2 automation script
        const scriptPath = path.join(__dirname, 'booking-automation-v2.sh');
        
        // Check if script exists
        if (!fs.existsSync(scriptPath)) {
            return res.status(500).json({ error: 'V2 Automation script not found' });
        }
        
        // Spawn the V2 automation process
        const automationProcess = spawn('./booking-automation-v2.sh', [deviceId, city], {
            cwd: __dirname,
            detached: true,
            stdio: ['ignore', 'pipe', 'pipe']
        });
        
        // Store the process
        runningProcesses.set(processKey, automationProcess);
        
        // Broadcast status update
        if (wss) {
            broadcastStatus();
        }
        
        // Handle process output
        automationProcess.stdout.on('data', (data) => {
            console.log(`📱 V2-${deviceId}: ${data.toString()}`);
        });
        
        automationProcess.stderr.on('data', (data) => {
            console.error(`❌ V2-${deviceId}: ${data.toString()}`);
        });
        
        automationProcess.on('close', (code) => {
            console.log(`✅ V2 Automation completed for ${city} with code ${code}`);
            runningProcesses.delete(processKey);
            // Broadcast status update
            if (wss) {
                broadcastStatus();
            }
        });
        
        automationProcess.on('error', (error) => {
            console.error(`💥 V2 Process error: ${error.message}`);
            runningProcesses.delete(processKey);
            // Broadcast status update
            if (wss) {
                broadcastStatus();
            }
        });
        
        // Detach the process so it can run independently
        automationProcess.unref();
        
        res.json({ 
            success: true, 
            message: `V2 Enhanced automation started for ${city}`,
            processId: automationProcess.pid,
            estimatedTime: '12-25 minutes (dynamic)',
            version: 'V2',
            features: [
                'Random timing variation',
                'Dynamic image counts (5-20 per hotel)',
                'Smart hotel selection',
                'Intelligent scrolling patterns'
            ]
        });
        
    } catch (error) {
        console.error('💥 V2 Server error:', error);
        res.status(500).json({ error: error.message });
    }
});

// API endpoint to start V1 automation (fallback)
app.post('/api/start-automation', async (req, res) => {
    try {
        const { deviceId, city } = req.body;
        
        if (!deviceId || !city) {
            return res.status(400).json({ error: 'Device ID and city are required' });
        }
        
        console.log(`🚀 Starting V1 automation for ${city} on device ${deviceId}`);
        
        // Kill any existing process for this device
        const processKey = `v1-${deviceId}-${city}`;
        if (runningProcesses.has(processKey)) {
            console.log('⚠️ Killing existing V1 process...');
            runningProcesses.get(processKey).kill();
            runningProcesses.delete(processKey);
        }
        
        // Path to the V1 automation script (in parent directory)
        const scriptPath = path.join(__dirname, '..', 'web-automation', 'booking-automation.sh');
        
        // Check if script exists
        if (!fs.existsSync(scriptPath)) {
            return res.status(500).json({ error: 'V1 Automation script not found' });
        }
        
        // Spawn the V1 automation process
        const automationProcess = spawn('../web-automation/booking-automation.sh', [deviceId, city], {
            cwd: __dirname,
            detached: true,
            stdio: ['ignore', 'pipe', 'pipe']
        });
        
        // Store the process
        runningProcesses.set(processKey, automationProcess);
        
        // Handle process output
        automationProcess.stdout.on('data', (data) => {
            console.log(`📱 V1-${deviceId}: ${data.toString()}`);
        });
        
        automationProcess.stderr.on('data', (data) => {
            console.error(`❌ V1-${deviceId}: ${data.toString()}`);
        });
        
        automationProcess.on('close', (code) => {
            console.log(`✅ V1 Automation completed for ${city} with code ${code}`);
            runningProcesses.delete(processKey);
        });
        
        automationProcess.on('error', (error) => {
            console.error(`💥 V1 Process error: ${error.message}`);
            runningProcesses.delete(processKey);
        });
        
        // Detach the process so it can run independently
        automationProcess.unref();
        
        res.json({ 
            success: true, 
            message: `V1 Standard automation started for ${city}`,
            processId: automationProcess.pid,
            estimatedTime: '15-20 minutes',
            version: 'V1'
        });
        
    } catch (error) {
        console.error('💥 V1 Server error:', error);
        res.status(500).json({ error: error.message });
    }
});

// API endpoint to start V3 automation
app.post('/api/start-automation-v3', async (req, res) => {
    try {
        const { deviceId, city } = req.body;
        
        if (!deviceId || !city) {
            return res.status(400).json({ error: 'Device ID and city are required' });
        }
        
        console.log(`🔥 Starting V3 automation for ${city} on device ${deviceId}`);
        
        // Kill any existing process for this device
        const processKey = `v3-${deviceId}-${city}`;
        if (runningProcesses.has(processKey)) {
            console.log('⚠️ Killing existing V3 process...');
            runningProcesses.get(processKey).kill();
            runningProcesses.delete(processKey);
        }
        
        // Path to the V3 automation script
        const scriptPath = path.join(__dirname, 'booking-automation-v3.sh');
        
        // Check if script exists
        if (!fs.existsSync(scriptPath)) {
            return res.status(500).json({ error: 'V3 Automation script not found' });
        }
        
        // Spawn the V3 automation process
        const automationProcess = spawn('./booking-automation-v3.sh', [deviceId, city], {
            cwd: __dirname,
            detached: true,
            stdio: ['ignore', 'pipe', 'pipe']
        });
        
        // Store the process
        runningProcesses.set(processKey, automationProcess);
        
        // Broadcast status update
        if (wss) {
            broadcastStatus();
        }
        
        // Handle process output
        automationProcess.stdout.on('data', (data) => {
            console.log(`📱 V3-${deviceId}: ${data.toString()}`);
        });
        
        automationProcess.stderr.on('data', (data) => {
            console.error(`❌ V3-${deviceId}: ${data.toString()}`);
        });
        
        automationProcess.on('close', (code) => {
            console.log(`✅ V3 Automation completed for ${city} with code ${code}`);
            runningProcesses.delete(processKey);
            // Broadcast status update
            if (wss) {
                broadcastStatus();
            }
        });
        
        automationProcess.on('error', (error) => {
            console.error(`💥 V3 Process error: ${error.message}`);
            runningProcesses.delete(processKey);
            // Broadcast status update
            if (wss) {
                broadcastStatus();
            }
        });
        
        // Detach the process so it can run independently
        automationProcess.unref();
        
        res.json({ 
            success: true, 
            message: `V3 Extended automation started for ${city}`,
            processId: automationProcess.pid,
            estimatedTime: '30 minutes (extended deep browsing)',
            version: 'V3',
            features: [
                'Extended 30-minute deep browsing',
                'Advanced hotel exploration patterns',
                'Multiple search refinements',
                'Enhanced human-like behavior',
                'Comprehensive hotel analysis'
            ]
        });
        
    } catch (error) {
        console.error('💥 V3 Server error:', error);
        res.status(500).json({ error: error.message });
    }
});

// API endpoint to check status
app.get('/api/status', (req, res) => {
    const activeProcesses = Array.from(runningProcesses.keys());
    const v1Processes = activeProcesses.filter(key => key.startsWith('v1-'));
    const v2Processes = activeProcesses.filter(key => key.startsWith('v2-'));
    const v3Processes = activeProcesses.filter(key => key.startsWith('v3-'));
    
    res.json({
        activeProcesses,
        v1Count: v1Processes.length,
        v2Count: v2Processes.length,
        v3Count: v3Processes.length,
        totalCount: activeProcesses.length,
        v1Processes,
        v2Processes,
        v3Processes
    });
});

// API endpoint to get device list
app.get('/api/devices', (req, res) => {
    const devices = [];
    
    // Add devices that are currently running automations
    runningProcesses.forEach((process, processKey) => {
        const [version, deviceId, city] = processKey.split('-');
        if (deviceId && !devices.find(d => d.id === deviceId)) {
            devices.push({
                id: deviceId,
                status: 'online',
                type: deviceId.includes(':') ? 'wireless' : 'usb',
                currentAutomation: {
                    version: version.toUpperCase(),
                    city: city
                }
            });
        }
    });
    
    res.json({ devices });
});

// API endpoint to stop automation
app.post('/api/stop-automation', (req, res) => {
    const { deviceId, city, version } = req.body;
    const processKey = `${version || 'v1'}-${deviceId}-${city}`;
    
    if (runningProcesses.has(processKey)) {
        const process = runningProcesses.get(processKey);
        process.kill('SIGTERM');
        runningProcesses.delete(processKey);
        
        // Broadcast update if WebSocket is available
        if (wss) {
            broadcastStatus();
        }
        
        res.json({ success: true, message: `${version || 'V1'} Automation stopped` });
    } else {
        res.status(404).json({ error: 'No running automation found' });
    }
});

// API endpoint to pause automation
app.post('/api/pause-automation', (req, res) => {
    const { processKey } = req.body;
    
    if (runningProcesses.has(processKey)) {
        const process = runningProcesses.get(processKey);
        try {
            process.kill('SIGSTOP'); // Pause the process
            
            // Broadcast update if WebSocket is available
            if (wss) {
                broadcastStatus();
            }
            
            res.json({ success: true, message: `Paused automation ${processKey}` });
        } catch (error) {
            res.json({ success: false, error: `Failed to pause: ${error.message}` });
        }
    } else {
        res.json({ success: false, error: 'Process not found' });
    }
});

// API endpoint to resume automation
app.post('/api/resume-automation', (req, res) => {
    const { processKey } = req.body;
    
    if (runningProcesses.has(processKey)) {
        const process = runningProcesses.get(processKey);
        try {
            process.kill('SIGCONT'); // Resume the process
            
            // Broadcast update if WebSocket is available
            if (wss) {
                broadcastStatus();
            }
            
            res.json({ success: true, message: `Resumed automation ${processKey}` });
        } catch (error) {
            res.json({ success: false, error: `Failed to resume: ${error.message}` });
        }
    } else {
        res.json({ success: false, error: 'Process not found' });
    }
});

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({ 
        status: 'healthy', 
        timestamp: new Date().toISOString(),
        version: 'V2 Enhanced',
        features: [
            'V1 Standard automation support',
            'V2 Enhanced automation with smart features',
            'Random timing variation',
            'Dynamic image counts',
            'Smart hotel selection',
            'Intelligent scrolling patterns'
        ]
    });
});

// Serve the dashboard
app.get('/dashboard', (req, res) => {
    res.sendFile(path.join(__dirname, 'dashboard.html'));
});

// Serve the main page
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});

// Start the server
server.listen(PORT, '0.0.0.0', () => {
    console.log(`🌐 Hotel Automation V2 Server running on port ${PORT}`);
    console.log(`📱 Access from anywhere: http://your-server-ip:${PORT}`);
    console.log(`📊 Dashboard: http://your-server-ip:${PORT}/dashboard`);
    console.log(`🏨 Ready to automate hotel bookings with V1 & V2!`);
    console.log(`🆕 V2 Features: Random timing, Dynamic browsing, Smart selection`);
    if (wss) {
        console.log(`📡 Real-time dashboard with WebSocket support enabled`);
    }
});

// Graceful shutdown
process.on('SIGTERM', () => {
    console.log('🛑 Shutting down V2 server...');
    // Kill all running processes
    runningProcesses.forEach((process, key) => {
        console.log(`⚠️ Killing process: ${key}`);
        process.kill();
    });
    server.close(() => {
        process.exit(0);
    });
});

process.on('SIGINT', () => {
    console.log('🛑 Shutting down V2 server...');
    // Kill all running processes
    runningProcesses.forEach((process, key) => {
        console.log(`⚠️ Killing process: ${key}`);
        process.kill();
    });
    server.close(() => {
        process.exit(0);
    });
}); 