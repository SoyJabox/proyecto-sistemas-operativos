#!/bin/bash
# Pruebas de casos borde para app.sh

PASSED=0
FAILED=0

VERDE="\033[0;32m"
ROJO="\033[0;31m"
RESET="\033[0m"

assert_contains() {
  local output="$1"
  local expected="$2"
  local test_name="$3"

  if echo "$output" | grep -q "$expected"; then
    echo -e "${VERDE}[PASS]${RESET} $test_name"
    ((PASSED++))
  else
    echo -e "${ROJO}[FAIL]${RESET} $test_name"
    ((FAILED++))
  fi
}

echo "=== PRUEBAS DE CASOS BORDE ==="
cp -r db db_backup_edge

# Borde 1: CI no numérica en alta
OUT=$(printf "1\nABCD1234\n5\n" | bash app.sh)
assert_contains "$OUT" "Debes ingresar entre 7 y 9 digitos numericos" "Borde 1: Rechazar CI no numérica"

# Borde 2: Cuota no numérica en alta
OUT=$(printf "1\n99887766\nLucas\nSilva\n099000111\nGRATIS\n5\n" | bash app.sh)
assert_contains "$OUT" "La cuota debe ser un valor numerico" "Borde 2: Rechazar cuota no numérica en alta"

# Borde 3: Médico inexistente en alta
OUT=$(printf "1\n99887766\nLucas\nSilva\n099000111\n2000\nMP999\n5\n" | bash app.sh)
assert_contains "$OUT" "no existe en la lista de medicos" "Borde 3: Rechazar médico inexistente en alta"

# Borde 4: Volver con 0 en alta
OUT=$(printf "1\n0\n5\n" | bash app.sh)
assert_contains "$OUT" "Volviendo al menu..." "Borde 4: Cancelar alta con 0"

# Borde 5: Paciente inexistente en consulta de socio
OUT=$(printf "4\n2\n999999999\n5\n" | bash app.sh)
assert_contains "$OUT" "No se encontro ningun socio" "Borde 5: Paciente no encontrado en consulta 2"

# Borde 6: Paciente inexistente en modificación
OUT=$(printf "3\n999999999\n5\n" | bash app.sh)
assert_contains "$OUT" "No se encontro ningun paciente" "Borde 6: Paciente no encontrado en modificación"

rm -rf db
mv db_backup_edge db

echo "================================"
echo -e "RESULTADOS CASOS BORDE: ${VERDE}${PASSED} PASARON${RESET} | ${ROJO}${FAILED} FALLARON${RESET}"
echo "================================"
