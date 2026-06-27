#!/bin/bash

set -e

echo "🚀 START"

if [ ! -s idea.md ]; then
  echo "❌ idea.md ist leer. Bitte beschreibe deine App-Idee zuerst in idea.md."
  exit 1
fi

# Helper: concatenate context files with separators
ctx() {
  for f in "$@"; do
    echo "--- $(basename "$f") ---"
    cat "$f"
    echo
  done
}

# PO Interview (interaktiv: Claude stellt Fragen, Nutzer antwortet)
echo "🎤 PO Interview..."
claude --append-system-prompt "$(cat prompts/po.md)" "$(cat idea.md)"
echo "👉 Beantworte Fragen in idea.md oder separat – Enter zum Fortfahren"
read

# Epics
echo "📋 Generiere Epics..."
claude -p --system-prompt "$(cat prompts/po.md)" \
  "$(ctx idea.md)
Führe PHASE 2 (EPICS) aus." > docs/01_epics.md
echo "👉 REVIEW docs/01_epics.md – Enter zum Fortfahren"
read

# User Stories
echo "📝 Generiere User Stories..."
claude -p --system-prompt "$(cat prompts/po.md)" \
  "$(ctx idea.md docs/01_epics.md)
Führe PHASE 3 (USER STORIES) aus." > docs/02_user_stories.md
echo "👉 REVIEW docs/02_user_stories.md – Enter zum Fortfahren"
read

# UX Review
echo "🎨 UX Review..."
claude -p --system-prompt "$(cat prompts/ux.md)" \
  "$(ctx docs/02_user_stories.md)
Führe PHASE 1 (REVIEW) aus." > docs/03_ux_review.md
echo "👉 REVIEW docs/03_ux_review.md, passe ggf. User Stories an – Enter zum Fortfahren"
read

# UX Design
echo "🎨 UX Design..."
claude -p --system-prompt "$(cat prompts/ux.md)" \
  "$(ctx docs/02_user_stories.md)
Führe PHASE 2 (DESIGN) aus." > docs/04_ux_design.md
echo "👉 REVIEW docs/04_ux_design.md – Enter zum Fortfahren"
read

# Arch Review
echo "🏗️  Architektur-Review..."
claude -p --system-prompt "$(cat prompts/architect.md)" \
  "$(ctx docs/02_user_stories.md docs/04_ux_design.md)
Führe PHASE 1 (REVIEW) aus." > docs/05_arch_review.md
echo "👉 REVIEW docs/05_arch_review.md, passe ggf. Anforderungen an – Enter zum Fortfahren"
read

# Architektur
echo "🏗️  Erstelle Architektur..."
claude -p --system-prompt "$(cat prompts/architect.md)" \
  "$(ctx docs/04_ux_design.md)
Führe PHASE 2 (ARCHITEKTUR) aus." > docs/06_architecture.md
echo "👉 REVIEW docs/06_architecture.md – Enter zum Fortfahren"
read

# Dev (interaktiv: generiert src/ und docs/07_implementation.md)
echo "💻 Entwicklung (interaktiv)..."
claude --append-system-prompt "$(cat prompts/dev.md)" \
  "$(ctx docs/06_architecture.md docs/02_user_stories.md)"
echo "👉 Entwicklung abgeschlossen – Enter zum Fortfahren mit Tests"
read

# Test (liest src/ selbständig via Tools)
echo "🧪 Erstelle Testbericht..."
claude -p --append-system-prompt "$(cat prompts/tester.md)" \
  "Erstelle den Testbericht gemäß deinen Anweisungen. Lies alle relevanten Dateien in docs/ und src/." \
  > docs/08_test_report.md

echo "✅ DONE"
