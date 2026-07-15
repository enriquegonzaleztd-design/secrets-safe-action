#!/bin/sh
set -eu

APP_USER="appuser"
APP_GROUP="appgroup"
APP_HOME="/home/${APP_USER}"

# GitHub monta esta carpeta desde el self-hosted runner.
FILE_COMMANDS_DIR="/github/file_commands"

if [ ! -d "${FILE_COMMANDS_DIR}" ]; then
    echo "Error: ${FILE_COMMANDS_DIR} does not exist."
    exit 1
fi

# Obtener el UID y GID efectivos del directorio montado desde el runner.
RUNNER_UID="$(stat -c '%u' "${FILE_COMMANDS_DIR}")"
RUNNER_GID="$(stat -c '%g' "${FILE_COMMANDS_DIR}")"

echo "Using runner filesystem UID=${RUNNER_UID} GID=${RUNNER_GID}"

# Crear o reutilizar un grupo con el GID requerido.
EXISTING_GROUP="$(getent group "${RUNNER_GID}" | cut -d: -f1 || true)"

if [ -n "${EXISTING_GROUP}" ]; then
    APP_GROUP="${EXISTING_GROUP}"
else
    addgroup -g "${RUNNER_GID}" "${APP_GROUP}"
fi

# Crear el usuario con el UID del filesystem del runner.
if ! id "${APP_USER}" >/dev/null 2>&1; then
    adduser \
        -u "${RUNNER_UID}" \
        -G "${APP_GROUP}" \
        -h "${APP_HOME}" \
        -s /bin/sh \
        -D \
        "${APP_USER}"
fi

# Asegurar acceso al código y al home temporal de GitHub.
chown -R "${RUNNER_UID}:${RUNNER_GID}" /usr/src/app

if [ -d /github/home ]; then
    chown -R "${RUNNER_UID}:${RUNNER_GID}" /github/home
fi

# Ejecutar la aplicación como usuario no privilegiado.
exec su-exec "${RUNNER_UID}:${RUNNER_GID}" \
    python /usr/src/app/main.py "$@"
