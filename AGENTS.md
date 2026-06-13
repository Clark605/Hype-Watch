# Copilot Tool Configuration

## Dart MCP Tooling Discipline

Flutter and Dart work MUST use the Dart MCP toolchain whenever a supported tool exists; shell commands are fallback only when no tool covers the task.
- Runtime and app control MUST prefer these tools:
  - `mcp_dart_sdk_mcp__connect_dart_tooling_daemon`
  - `mcp_dart_sdk_mcp__create_project`
  - `mcp_dart_sdk_mcp__hot_reload`
  - `mcp_dart_sdk_mcp__hot_restart`
  - `mcp_dart_sdk_mcp__stop_app`
- Debugging and runtime inspection MUST use these tools:
  - `mcp_dart_sdk_mcp__get_runtime_errors`
  - `mcp_dart_sdk_mcp__flutter_driver`
- Pub.dev package operations MUST use `mcp_dart_sdk_mcp__pub` for dependency
  management, including `add`, `get`, `remove`, `upgrade`, `deps`, and
  `outdated`.
- Pub.dev package discovery/search MUST happen before dependency changes by
  checking the package catalog on pub.dev or the closest available discovery
  tool, so package selection is based on current package metadata rather than
  guesswork.
- Repository search MUST use workspace search tools instead of shell search:
  - `semantic_search`
  - `grep_search`
  - `file_search`
- If no MCP tool covers the task, the smallest necessary fallback MAY be used,
  but the gap and fallback reason MUST be stated before proceeding.

## GitHub MCP Tooling Discipline

Any GitHub workflow MUST use the GitHub MCP server tools whenever a supported tool exists. This includes fetching, creating, updating, or publishing PRs and issues, managing review comments, checking pull request status, handling Copilot code review, and any other repository-hosted GitHub operation.
- Use GitHub MCP tools for PR and issue lifecycle actions instead of shelling out to `gh` or the GitHub web UI when a supported tool exists.
- Use GitHub MCP tools for Copilot review and review-comment workflows when supported.
- If a GitHub task cannot be completed with a GitHub MCP tool, use the smallest necessary fallback and state the gap before proceeding.
