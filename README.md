# MSSQL MCP Server

A [Model Context Protocol](https://modelcontextprotocol.io/) (MCP) server for querying Microsoft SQL Server databases from Claude Code or Claude Desktop.

Forked from [RichardHan/mssql_mcp_server](https://github.com/RichardHan/mssql_mcp_server) with Swyfft-specific fixes:
- CTE (`WITH ... SELECT`) queries recognized as read-only SELECT statements
- Resource handler disabled to prevent timeout on large databases (9,000+ tables)
- Ruff linting cleanup

## Setup

### 1. Clone the repo

```bash
git clone git@github.com:swyfft-insurance/mssql_mcp_server.git
cd mssql_mcp_server
```

### 2. Create a virtual environment and install

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -e .
```

On Linux, you may need the FreeTDS development library first:

```bash
sudo apt install freetds-dev
```

### 3. Configure environment variables

Create a `.env` file (gitignored) or export directly:

```bash
# Required
MSSQL_SERVER=your-server.example.com
MSSQL_DATABASE=YourDatabase
MSSQL_USER=your_username
MSSQL_PASSWORD=your_password

# Optional
MSSQL_PORT=1433              # Default: 1433
MSSQL_ENCRYPT=true           # Force encryption (auto for Azure)
MSSQL_WINDOWS_AUTH=true      # Use Windows auth instead of SQL auth
```

For Windows Authentication, set `MSSQL_WINDOWS_AUTH=true` and omit `MSSQL_USER`/`MSSQL_PASSWORD`.

### 4. Add to Claude Code

Add the server to your project's `.mcp.json`:

```json
{
  "mcpServers": {
    "mssql": {
      "command": "/absolute/path/to/mssql_mcp_server/.venv/bin/mssql_mcp_server",
      "args": [],
      "env": {
        "MSSQL_SERVER": "${SWYFFT_MSSQL_SERVER}",
        "MSSQL_DATABASE": "${SWYFFT_MSSQL_DATABASE}",
        "MSSQL_USER": "${SWYFFT_MSSQL_USER}",
        "MSSQL_PASSWORD": "${SWYFFT_MSSQL_PASSWORD}"
      }
    }
  }
}
```

The `${VAR}` syntax references environment variables from your shell, so credentials stay out of the file. Add your exports to `~/.swyfft_credentials`:

```bash
export SWYFFT_MSSQL_SERVER=your-server.example.com
export SWYFFT_MSSQL_DATABASE=YourDatabase
export SWYFFT_MSSQL_USER=your_username
export SWYFFT_MSSQL_PASSWORD=your_password
```

Then source it from your `.bashrc`:

```bash
[ -f ~/.swyfft_credentials ] && source ~/.swyfft_credentials
```

Use the absolute path to the venv's entry point so Claude Code can find it regardless of working directory.

### 5. Add to Claude Desktop (alternative)

Add to `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "mssql": {
      "command": "/absolute/path/to/mssql_mcp_server/.venv/bin/mssql_mcp_server",
      "args": [],
      "env": {
        "MSSQL_SERVER": "your-server.example.com",
        "MSSQL_DATABASE": "YourDatabase",
        "MSSQL_USER": "your_username",
        "MSSQL_PASSWORD": "your_password"
      }
    }
  }
}
```

## Tools

The server exposes a single tool:

| Tool | Description |
|------|-------------|
| `execute_sql` | Execute a SQL query against the configured database. SELECT and CTE (`WITH`) queries return results as CSV. Non-SELECT queries return affected row count. |

## Verify it works

Start a new Claude Code session from any directory. You should see the `mssql` server in the status bar. Run a test query:

```
> run: SELECT TOP 1 name FROM sys.tables
```

## Security notes

- Store credentials in `~/.swyfft_credentials` (never committed) and reference them via `${VAR}` in `.mcp.json`
- Use a read-only SQL account when possible
- The server does not restrict query types — access control is your responsibility

## Development

```bash
make install-dev   # Install with dev dependencies
make test          # Run tests
make lint          # Check formatting
make format        # Auto-format
```

## License

MIT
