const express = require('express');
const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');
const http = require('http');
const WebSocket = require('ws');

const app = express();
const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(express.static(__dirname));

// Store running processes and their states
const runningProcesses = new Map();
const processStates = new Map(); // Store pause/resume states
const logStreams = new Map(); // Store log file watchers
const dashboardClients = new Set(); // WebSocket clients

// WebSocket connection handler
wss.on('connection', (ws) => {
    console.log('📡 Dashboard client connected');
    dashboardClients.add(ws);
    
    // Send initial status
    ws.send(JSON.stringify({
        type: 'status',
        data: getSystemStatus()
    }));
    
    ws.on('close', () => {
        console.log('📡 Dashboard client disconnected');
        dashboardClients.delete(ws);
    });
    
    ws.on('message', (message) => {
        try {
            const data = JSON.parse(message);
            handleWebSocketMessage(ws, data);
        } catch (error) {
            console.error('❌ WebSocket message error:', error);
        }
    });
});

// Broadcast to all dashboard clients
function broadcastToDashboard(message) {
    const messageStr = JSON.stringify(message);
    dashboardClients.forEach(client => {
        if (client.readyState === WebSocket.OPEN) {
            client.send(messageStr);
        }
    });
}

// Handle WebSocket messages
function handleWebSocketMessage(ws, data) {
    switch (data.type) {
        case 'requestLogs':
            streamLogsToClient(ws, data.processKey);
            break;
        case 'pauseProcess':
            pauseProcess(data.processKey);
            break;
        case 'resumeProcess':
            resumeProcess(data.processKey);
            break;
        case 'stopProcess':
            stopProcess(data.processKey);
            break;
    }
}

// Get system status
function getSystemStatus() {
    const activeProcesses = Array.from(runningProcesses.keys());
    const v1Processes = activeProcesses.filter(key => key.startsWith('v1-'));
    const v2Processes = activeProcesses.filter(key => key.startsWith('v2-'));
    
    return {
        activeProcesses,
        v1Count: v1Processes.length,
        v2Count: v2Processes.length,
        totalCount: activeProcesses.length,
        v1Processes,
        v2Processes,
        processStates: Object.fromEntries(processStates),
        timestamp: new Date().toISOString()
    };
}

// Enhanced process spawning with real-time monitoring
function spawnAutomationProcess(scriptPath, args, processKey, version) {
    const automationProcess = spawn(scriptPath, args, {
        cwd: __dirname,
        detached: true,
        stdio: ['ignore', 'pipe', 'pipe']
    });
    
    // Store the process
    runningProcesses.set(processKey, automationProcess);
    processStates.set(processKey, 'running');
    
    // Real-time log streaming
    const logBuffer = [];
    
    // Handle process output
    automationProcess.stdout.on('data', (data) => {
        const logLine = data.toString();
        console.log(`📱 ${version}-${processKey}: ${logLine}`);
        
        // Store log line and broadcast
        logBuffer.push({ type: 'stdout', data: logLine, timestamp: new Date().toISOString() });
        broadcastToDashboard({
            type: 'log',
            processKey,
            data: { type: 'stdout', data: logLine, timestamp: new Date().toISOString() }
        });
    });
    
    automationProcess.stderr.on('data', (data) => {
        const logLine = data.toString();
        console.error(`❌ ${version}-${processKey}: ${logLine}`);
        
        // Store log line and broadcast
        logBuffer.push({ type: 'stderr', data: logLine, timestamp: new Date().toISOString() });
        broadcastToDashboard({
            type: 'log',
            processKey,
            data: { type: 'stderr', data: logLine, timestamp: new Date().toISOString() }
        });
    });
    
    automationProcess.on('close', (code) => {
        console.log(`✅ ${version} Automation completed for ${processKey} with code ${code}`);
        runningProcesses.delete(processKey);
        processStates.delete(processKey);
        
        // Broadcast completion
        broadcastToDashboard({
            type: 'processComplete',
            processKey,
            exitCode: code,
            timestamp: new Date().toISOString()
        });
        
        // Broadcast updated status
        broadcastToDashboard({
            type: 'status',
            data: getSystemStatus()
        });
    });
    
    automationProcess.on('error', (error) => {
        console.error(`💥 ${version} Process error: ${error.message}`);
        runningProcesses.delete(processKey);
        processStates.delete(processKey);
        
        // Broadcast error
        broadcastToDashboard({
            type: 'processError',
            processKey,
            error: error.message,
            timestamp: new Date().toISOString()
        });
    });
    
    // Detach the process so it can run independently
    automationProcess.unref();
    
    // Broadcast updated status
    broadcastToDashboard({
        type: 'status',
        data: getSystemStatus()
    });
    
    return automationProcess;
}

// Pause process (simulate by sending SIGSTOP)
function pauseProcess(processKey) {
    if (runningProcesses.has(processKey)) {
        try {
            const process = runningProcesses.get(processKey);
            process.kill('SIGSTOP');
            processStates.set(processKey, 'paused');
            
            broadcastToDashboard({
                type: 'processPaused',
                processKey,
                timestamp: new Date().toISOString()
            });
            
            console.log(`⏸️ Process paused: ${processKey}`);
        } catch (error) {
            console.error(`❌ Failed to pause process ${processKey}:`, error);
        }
    }
}

// Resume process (simulate by sending SIGCONT)
function resumeProcess(processKey) {
    if (runningProcesses.has(processKey)) {
        try {
            const process = runningProcesses.get(processKey);
            process.kill('SIGCONT');
            processStates.set(processKey, 'running');
            
            broadcastToDashboard({
                type: 'processResumed',
                processKey,
                timestamp: new Date().toISOString()
            });
            
            console.log(`▶️ Process resumed: ${processKey}`);
        } catch (error) {
            console.error(`❌ Failed to resume process ${processKey}:`, error);
        }
    }
}

// Stop process
function stopProcess(processKey) {
    if (runningProcesses.has(processKey)) {
        try {
            const process = runningProcesses.get(processKey);
            process.kill('SIGTERM');
            runningProcesses.delete(processKey);
            processStates.delete(processKey);
            
            broadcastToDashboard({
                type: 'processStopped',
                processKey,
                timestamp: new Date().toISOString()
            });
            
            console.log(`⏹️ Process stopped: ${processKey}`);
        } catch (error) {
            console.error(`❌ Failed to stop process ${processKey}:`, error);
        }
    }
}

// Stream logs to specific client
function streamLogsToClient(ws, processKey) {
    const logFile = path.join(__dirname, 'midscene_run', 'log', 'ai-call.log');
    
    if (fs.existsSync(logFile)) {
        // Read existing log content
        const logContent = fs.readFileSync(logFile, 'utf8');
        const lines = logContent.split('\n').slice(-50); // Last 50 lines
        
        lines.forEach(line => {
            if (line.trim()) {
                ws.send(JSON.stringify({
                    type: 'log',
                    processKey,
                    data: { type: 'file', data: line, timestamp: new Date().toISOString() }
                }));
            }
        });
        
        // Watch for new log entries
        const watcher = fs.watchFile(logFile, (curr, prev) => {
            if (curr.mtime > prev.mtime) {
                // File was modified, read new content
                const newContent = fs.readFileSync(logFile, 'utf8');
                const newLines = newContent.split('\n').slice(-10); // Last 10 lines
                
                newLines.forEach(line => {
                    if (line.trim()) {
                        ws.send(JSON.stringify({
                            type: 'log',
                            processKey,
                            data: { type: 'file', data: line, timestamp: new Date().toISOString() }
                        }));
                    }
                });
            }
        });
        
        // Clean up watcher when client disconnects
        ws.on('close', () => {
            fs.unwatchFile(logFile);
        });
    }
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
        
        // Spawn the V2 automation process with enhanced monitoring
        const automationProcess = spawnAutomationProcess(
            './booking-automation-v2.sh',
            [deviceId, city],
            processKey,
            'V2'
        );
        
        res.json({ 
            success: true, 
            message: `V2 Enhanced automation started for ${city}`,
            processId: automationProcess.pid,
            processKey: processKey,
            estimatedTime: '12-25 minutes (dynamic)',
            version: 'V2',
            features: [
                'Random timing variation',
                'Dynamic image counts (5-20 per hotel)',
                'Smart hotel selection',
                'Intelligent scrolling patterns',
                'Real-time monitoring',
                'Pause/Resume capability'
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
        
        // Spawn the V1 automation process with enhanced monitoring
        const automationProcess = spawnAutomationProcess(
            '../web-automation/booking-automation.sh',
            [deviceId, city],
            processKey,
            'V1'
        );
        
        res.json({ 
            success: true, 
            message: `V1 Standard automation started for ${city}`,
            processId: automationProcess.pid,
            processKey: processKey,
            estimatedTime: '15-20 minutes',
            version: 'V1',
            features: [
                'Real-time monitoring',
                'Pause/Resume capability'
            ]
        });
        
    } catch (error) {
        console.error('💥 V1 Server error:', error);
        res.status(500).json({ error: error.message });
    }
});

// API endpoint to check status
app.get('/api/status', (req, res) => {
    res.json(getSystemStatus());
});

// API endpoint to pause automation
app.post('/api/pause-automation', (req, res) => {
    const { processKey } = req.body;
    
    if (!processKey) {
        return res.status(400).json({ error: 'Process key is required' });
    }
    
    if (runningProcesses.has(processKey)) {
        pauseProcess(processKey);
        res.json({ success: true, message: `Process paused: ${processKey}` });
    } else {
        res.status(404).json({ error: 'Process not found' });
    }
});

// API endpoint to resume automation
app.post('/api/resume-automation', (req, res) => {
    const { processKey } = req.body;
    
    if (!processKey) {
        return res.status(400).json({ error: 'Process key is required' });
    }
    
    if (runningProcesses.has(processKey)) {
        resumeProcess(processKey);
        res.json({ success: true, message: `Process resumed: ${processKey}` });
    } else {
        res.status(404).json({ error: 'Process not found' });
    }
});

// API endpoint to stop automation
app.post('/api/stop-automation', (req, res) => {
    const { deviceId, city, version, processKey } = req.body;
    
    let targetProcessKey = processKey;
    if (!targetProcessKey && deviceId && city) {
        targetProcessKey = `${version || 'v1'}-${deviceId}-${city}`;
    }
    
    if (!targetProcessKey) {
        return res.status(400).json({ error: 'Process key or device/city info required' });
    }
    
    if (runningProcesses.has(targetProcessKey)) {
        stopProcess(targetProcessKey);
        res.json({ success: true, message: `Process stopped: ${targetProcessKey}` });
    } else {
        res.status(404).json({ error: 'No running automation found' });
    }
});

// API endpoint to get device list (simulated)
app.get('/api/devices', (req, res) => {
    // In a real implementation, this would call `adb devices`
    res.json({
        devices: [
            { id: '98.98.125.9:24142', status: 'online', type: 'wireless' },
            { id: '192.168.1.100:5555', status: 'offline', type: 'wireless' },
            { id: 'emulator-5554', status: 'online', type: 'emulator' }
        ]
    });
});

// API endpoint to get logs
app.get('/api/logs/:processKey', (req, res) => {
    const { processKey } = req.params;
    const logFile = path.join(__dirname, 'midscene_run', 'log', 'ai-call.log');
    
    if (fs.existsSync(logFile)) {
        const logContent = fs.readFileSync(logFile, 'utf8');
        const lines = logContent.split('\n').slice(-100); // Last 100 lines
        
        res.json({
            processKey,
            logs: lines.filter(line => line.trim()).map(line => ({
                data: line,
                timestamp: new Date().toISOString()
            }))
        });
    } else {
        res.json({ processKey, logs: [] });
    }
});

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({ 
        status: 'healthy', 
        timestamp: new Date().toISOString(),
        version: 'V2 Enhanced Dashboard',
        features: [
            'V1 Standard automation support',
            'V2 Enhanced automation with smart features',
            'Real-time WebSocket dashboard',
            'Pause/Resume functionality',
            'Live log streaming',
            'Device monitoring',
            'Performance metrics'
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
    console.log(`🌐 Hotel Automation V2 Enhanced Server running on port ${PORT}`);
    console.log(`📱 Main Interface: http://your-server-ip:${PORT}`);
    console.log(`📊 Dashboard: http://your-server-ip:${PORT}/dashboard`);
    console.log(`🏨 Ready to automate hotel bookings with V1 & V2!`);
    console.log(`🆕 V2 Features: Random timing, Dynamic browsing, Smart selection`);
    console.log(`📡 Real-time Dashboard: WebSocket monitoring, Pause/Resume, Live logs`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
    console.log('🛑 Shutting down V2 Enhanced server...');
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
    console.log('🛑 Shutting down V2 Enhanced server...');
    // Kill all running processes
    runningProcesses.forEach((process, key) => {
        console.log(`⚠️ Killing process: ${key}`);
        process.kill();
    });
    server.close(() => {
        process.exit(0);
    });
});