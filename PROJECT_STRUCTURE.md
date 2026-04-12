# Project Structure Reference

This document outlines the organized directory structure for the Forecast project.

## Directory Map

- **`/agroforecast_app`**: Flutter mobile application.
- **`/backend`**: .NET Web API following Clean Architecture.
- **`/etl`**: Python scripts for data scraping and forecast engines.
- **`/agents`**: Autonomous and semi-autonomous AI agents.
  - **`/n8n`**: Exported workflows and JSON configurations.
  - **`/script_agents`**: Python scripts for specialized AI tasks (LangChain/AutoGPT).
  - **`/prompts`**: System prompts and instruction templates.
- **`/docs`**: Technical manuals, PDFs, and research notes.

## Guidelines
- Keep agents independent from the core backend logic to allow rapid iteration.
- Use `AGENTS.md` in the root as the primary instruction set for AI development.
- Document all new n8n workflows in the `/agents/n8n` folder.
