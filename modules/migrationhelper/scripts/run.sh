#!/bin/sh
# URL rewrite runner. Runs in mcr.microsoft.com/mssql-tools with phase2_*.sql
# mounted at /scripts.

set -e

SQLCMD=/opt/mssql-tools/bin/sqlcmd

info() { echo "$@" >&2 ; }
heading() { info ; info "==>" "$@" ; }
die() { info "ERROR:" "$@" ; exit 1 ; }

heading "XMPro Migration Helper (URL updates)"

# Required env vars
[ "${SQLCMDSERVER}" ] || die "SQLCMDSERVER not set"
[ "${SMDB_USER}" ] || die "SMDB_USER not set"
[ "${SMDB_PASSWORD}" ] || die "SMDB_PASSWORD not set"
[ "${ADDB_USER}" ] || die "ADDB_USER not set"
[ "${ADDB_PASSWORD}" ] || die "ADDB_PASSWORD not set"
[ "${DSDB_USER}" ] || die "DSDB_USER not set"
[ "${DSDB_PASSWORD}" ] || die "DSDB_PASSWORD not set"

SMDB_NAME="${SMDB_NAME:-SM}"
ADDB_NAME="${ADDB_NAME:-AD}"
DSDB_NAME="${DSDB_NAME:-DS}"

heading "Database names: SM=$SMDB_NAME, AD=$ADDB_NAME, DS=$DSDB_NAME"

# Always encrypt + trust server cert (Azure SQL)
SQL_FLAGS="-N -C -r 1 -b -S $SQLCMDSERVER"

# Strip trailing slashes from URLs
strip_slash() { echo "$1" | sed 's|/*$||'; }
ad_url=$(strip_slash "${AD_BASEURL_CLIENT:-}")
ds_url=$(strip_slash "${DS_BASEURL_CLIENT:-}")
ai_url=$(strip_slash "${AI_BASEURL_CLIENT:-}")
nb_url=$(strip_slash "${XMPRO_NOTEBOOK_BASEURL_CLIENT:-}")

# Wait for SQL Server (Azure SQL password propagation can take ~1m)
heading "Waiting for SQL Server connectivity"
max_wait=120
elapsed=0
while [ "$elapsed" -lt "$max_wait" ]; do
    if SQLCMDPASSWORD="$SMDB_PASSWORD" "$SQLCMD" $SQL_FLAGS \
        -U "$SMDB_USER" -d "$SMDB_NAME" -Q "SELECT 1" -h -1 -W > /dev/null 2>&1; then
        info "SQL Server connected after ${elapsed}s"
        break
    fi
    info "  Not ready yet, waited ${elapsed}s / ${max_wait}s"
    sleep 10
    elapsed=$((elapsed + 10))
done
[ "$elapsed" -lt "$max_wait" ] || die "SQL Server not reachable after ${max_wait}s"

# sed-substitute URLs into a writable copy because older sqlcmd's -v breaks on https://
EMPTY="__NONE__"
WORK=/tmp/phase2
mkdir -p "$WORK"

render() {
    sed \
        -e "s|\$(AD_URL)|${ad_url:-$EMPTY}|g" \
        -e "s|\$(DS_URL)|${ds_url:-$EMPTY}|g" \
        -e "s|\$(AI_URL)|${ai_url:-$EMPTY}|g" \
        -e "s|\$(NB_URL)|${nb_url:-$EMPTY}|g" \
        "$1" > "$2"
}

heading "SM Database URL Updates"
render /scripts/phase2_sm.sql "$WORK/phase2_sm.sql"
SQLCMDPASSWORD="$SMDB_PASSWORD" "$SQLCMD" $SQL_FLAGS \
    -U "$SMDB_USER" -d "$SMDB_NAME" -i "$WORK/phase2_sm.sql"

if [ -n "$ad_url" ]; then
    heading "DS Database URL Updates"
    render /scripts/phase2_ds.sql "$WORK/phase2_ds.sql"
    SQLCMDPASSWORD="$DSDB_PASSWORD" "$SQLCMD" $SQL_FLAGS \
        -U "$DSDB_USER" -d "$DSDB_NAME" -i "$WORK/phase2_ds.sql"
else
    heading "DS Database URL Updates"
    info "Skipped (no AD_BASEURL_CLIENT provided)"
fi

if [ -n "$ds_url" ]; then
    heading "AD Database URL Updates"
    render /scripts/phase2_ad.sql "$WORK/phase2_ad.sql"
    SQLCMDPASSWORD="$ADDB_PASSWORD" "$SQLCMD" $SQL_FLAGS \
        -U "$ADDB_USER" -d "$ADDB_NAME" -i "$WORK/phase2_ad.sql"
else
    heading "AD Database URL Updates"
    info "Skipped (no DS_BASEURL_CLIENT provided)"
fi

heading "Migration complete"
