#!/usr/bin/env bash
# One command to build (if needed) and start the application.
cd "$(dirname "$0")"

# 1. compile the C backend when missing or older than its source
if [ ! -x backend/os_backend ] || [ backend/backend.c -nt backend/os_backend ]; then
  bash build.sh || exit 1
fi

# 2. Tkinter check (gives a clear message instead of a traceback)
if ! python3 -c "import tkinter" 2>/dev/null; then
  echo "Tkinter is missing.  Run:  sudo apt install python3-tk"; exit 1
fi

# 3. optional: ReportLab for PDF reports (everything else needs only the standard library)
PY=python3
if ! python3 -c "import reportlab" 2>/dev/null; then
  if [ ! -d .venv ]; then python3 -m venv --system-site-packages .venv 2>/dev/null; fi
  if [ -x .venv/bin/python ]; then
    .venv/bin/python -m pip install -q -r requirements.txt 2>/dev/null \
      && PY=.venv/bin/python \
      || echo "(Could not install reportlab - PDF export will be disabled; text/CSV still work.)"
    [ -x .venv/bin/python ] && .venv/bin/python -c "import reportlab" 2>/dev/null && PY=.venv/bin/python
  fi
fi

exec "$PY" frontend/main.py
