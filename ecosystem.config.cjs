module.exports = {
  apps: [
    {
      name: 'contentpilot-api',
      cwd: './backend',
      script: 'dist/index.js',
      instances: 1, // Single instance recommended for SQLite WAL coordination
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      restart_delay: 3000,
      time: true,
      error_file: '../logs/pm2-error.log',
      out_file: '../logs/pm2-out.log',
      env: {
        NODE_ENV: 'production',
        PORT: process.env.PORT || 3001,
      },
    },
    // Optional standalone worker process (if separating from API):
    // To use separate worker, set DISABLE_BACKGROUND_WORKERS=true on contentpilot-api
    // and uncomment the block below:
    /*
    {
      name: 'contentpilot-worker',
      cwd: './backend',
      script: 'dist/worker.js',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1.5G',
      env: {
        NODE_ENV: 'production',
      },
    },
    */
  ],
};
