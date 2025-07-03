# Hotel Booking Automation V2 - Enhanced Edition
FROM node:18-alpine

# Install system dependencies
RUN apk add --no-cache \
    bash \
    curl \
    wget \
    unzip \
    android-tools \
    && rm -rf /var/cache/apk/*

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install Node.js dependencies (including WebSocket)
RUN npm ci --only=production

# Copy application files
COPY . .

# Make scripts executable
RUN chmod +x booking-automation-v2.sh
RUN chmod +x start-dashboard.sh

# Create directories for Midscene
RUN mkdir -p midscene_run/log midscene_run/report

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Start the enhanced application with dashboard
CMD ["node", "server-enhanced.js"]