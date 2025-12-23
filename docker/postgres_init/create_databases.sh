#!/usr/bin/env bash
# This script is executed inside the Postgres container to ensure both the
# default DB (POSTGRES_DB) and a derived test DB (POSTGRES_DB_test) exist.
# It is idempotent: checks for the DB existence before creating.
set -euo pipefail

echo "[db-init] Starting database initialization..."
# Scripts in docker-entrypoint-initdb.d run AFTER Postgres is ready,
# so we don't need to wait. Connect using Unix socket (no -h flag).
export PGPASSWORD="${POSTGRES_PASSWORD}"

MAIN_DB="${POSTGRES_DB}"
# Allow an explicit test db name via POSTGRES_DB_TEST, else derive it
TEST_DB="${POSTGRES_DB_TEST:-${MAIN_DB}_test}"

create_db_if_missing() {
  DB_NAME="$1"
  # Check if DB exists
  EXISTS=$(psql -U "${POSTGRES_USER}" -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='${DB_NAME}'")
  if [ "${EXISTS}" = "1" ]; then
    echo "[db-init] Database '${DB_NAME}' already exists. Skipping creation."
  else
    echo "[db-init] Creating database '${DB_NAME}'..."
    psql -U "${POSTGRES_USER}" -d postgres -c "CREATE DATABASE \"${DB_NAME}\";"
    echo "[db-init] Created database '${DB_NAME}'."
  fi
}

# The official Postgres image already creates MAIN_DB (POSTGRES_DB) on first init.
# We still check and attempt to create it to be resilient in case the image doesn't.
create_db_if_missing "${MAIN_DB}"
create_db_if_missing "${TEST_DB}"

echo "[db-init] All done."

exit 0
