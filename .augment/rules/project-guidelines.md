---
type: "manual"
---
description: "This rule sets out general guidelines for project development. It specifies best practices for project management, version control, and collaboration. The rule also defines prohibited actions, such as the auto-generation of README files, to ensure that all changes are intentional and explicitly requested by the user."

# project-guidelines.md

## ⛔ Prohibited Actions

### NO Auto-Generated README Files
- **DO NOT** create or modify `README.md` files automatically at the end of tasks
- **DO NOT** generate documentation files unless explicitly requested by the user
- **DO NOT** assume documentation updates are needed

### When to Create/Update README
- Only when user explicitly requests: "Update README" or "Create documentation"
- Only when adding major new features that require documentation
- Only when user provides specific content to add

## ✅ What To Do Instead
- Summarize changes in the chat response
- Ask user if documentation updates are needed
- Wait for explicit user instruction before touching README files

---

## General Guidelines
- Focus on code changes only
- Respect user preferences
- Ask before making non-code modifications