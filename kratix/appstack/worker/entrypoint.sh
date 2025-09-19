#!/bin/sh
set -euo pipefail

# Variables del Work (Kratix monta el CR en /kratix/resource.yaml en muchas instalaciones;
# si cambia la ruta en tu versión, ajusta aquí).
CR=/kratix/resource.yaml

# Extrae parámetros clave para path
APP_NAME=$(yq -r '.spec.appName' "$CR")
NS=$(yq -r '.spec.namespace' "$CR")

WORKDIR=/out/environments/${NS}/${APP_NAME}
mkdir -p "$WORKDIR"

# Copia templates (si ya están renderizados por Kratix, genial; si no, usa gomplate/yq para render)
cp /templates/*.tmpl "$WORKDIR"/

# Git commit & push
git config --global user.email "${GIT_EMAIL}"
git config --global user.name "${GIT_USERNAME}"

mkdir -p /repo
cd /repo
git init
git remote add origin "${GIT_URL}"
git fetch origin "${GIT_BRANCH}" || true
git checkout -B "${GIT_BRANCH}" || git checkout -b "${GIT_BRANCH}"

mkdir -p "environments/${NS}/${APP_NAME}"
cp -R "${WORKDIR}/." "environments/${NS}/${APP_NAME}/"

git add environments/
git commit -m "appstack: ${NS}/${APP_NAME}"
git -c http.extraHeader="Authorization: Bearer ${GIT_TOKEN}" push -u origin "${GIT_BRANCH}"
echo "Done."
