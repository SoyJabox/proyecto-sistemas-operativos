#!/bin/bash
# Script de pruebas end-to-end (E2E) para app.sh

PASSED=0
FAILED=0

# Colores para salida clara
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
    echo -e "${ROJO}[FAIL]${RESET} $test_name (Se esperaba encontrar: '$expected')"
    ((FAILED++))
  fi
}

echo "=== INICIANDO PRUEBAS E2E ==="

# 1. Respaldo de la base de datos original antes de probar
cp -r db db_e2e_backup
cp -r .bak .bak_e2e_backup 2>/dev/null || true

# Test 1: Ayuda no interactiva (--help)
OUT=$(bash app.sh --help)
assert_contains "$OUT" "SISTEMA DE GESTION DE PACIENTES" "Test 1.1: Ayuda --help muestra encabezado"
assert_contains "$OUT" "ESTRUCTURA DE ARCHIVOS" "Test 1.2: Ayuda --help muestra estructura de archivos"

# Test 2: Salir directamente desde el menú principal
OUT=$(printf "5\n" | bash app.sh)
assert_contains "$OUT" "Saliendo del sistema..." "Test 2: Salir correctamente (Opción 5)"

# Test 3: Validar alta con CI repetida
OUT=$(printf "1\n123456789\n5\n" | bash app.sh)
assert_contains "$OUT" "ya esta registrado" "Test 3: Rechazar alta con CI repetida"

# Test 4: Alta exitosa de nuevo paciente
# CI: 55443322, Nombre: Esteban, Apellido: Morales, Tel: 091112233, Cuota: 2500, Medico: MP001, Fecha: default
OUT=$(printf "1\n55443322\nEsteban\nMorales\nM\n1.75\n35\n75\n091112233\n2500\nMP001\n\n5\n" | bash app.sh)
assert_contains "$OUT" "Paciente añadido exitosamente" "Test 4.1: Alta de paciente exitosa en consola"
CHECK_BD=$(grep "^55443322:Esteban:Morales:M:1.75:35:75:091112233:2500:MP001:" db/pacientes.txt || true)
if [[ -n "$CHECK_BD" ]]; then
  echo -e "${VERDE}[PASS]${RESET} Test 4.2: Registro persistido correctamente en db/pacientes.txt"
  ((PASSED++))
else
  echo -e "${ROJO}[FAIL]${RESET} Test 4.2: No se encontro el registro en db/pacientes.txt"
  ((FAILED++))
fi

# Test 5: Consultas
# 5.1 Pacientes por médico (MP001 tiene a Esteban)
OUT=$(printf "4\n1\nMP001\n5\n" | bash app.sh)
assert_contains "$OUT" "Esteban Morales" "Test 5.1: Consulta 1 - Pacientes del médico MP001"

# 5.2 Cuota de un socio determinado
OUT=$(printf "4\n2\n55443322\n5\n" | bash app.sh)
assert_contains "$OUT" "Cuota mensual: \$2500" "Test 5.2: Consulta 2 - Cuota del socio 55443322"

# 5.3 Médico de un paciente
OUT=$(printf "4\n3\n55443322\n5\n" | bash app.sh)
assert_contains "$OUT" "Roberto" "Test 5.3: Consulta 3 - Nombre del médico de cabecera"

# 5.4 Total mensual de cuotas sociales
# Base inicial: 16600 + 2500 de Esteban = 19100
OUT=$(printf "4\n4\n5\n" | bash app.sh)
assert_contains "$OUT" "\$19100" "Test 5.4: Consulta 4 - Total de ingresos mensual calculado"

# 5.5 Cantidad de pacientes por médico (consulta extra)
OUT=$(printf "4\n5\n5\n" | bash app.sh)
assert_contains "$OUT" "paciente(s)" "Test 5.5: Consulta 5 - Conteo de pacientes por médico"

# Test 6: Modificación de paciente (Cambiar cuota de 2500 a 3000)
# CI: 55443322, Opción campo 4 (Cuota), Nueva cuota: 3000
OUT=$(printf "3\n55443322\n8\n3000\n5\n" | bash app.sh)
assert_contains "$OUT" "Registro modificado exitosamente" "Test 6.1: Modificación exitosa en consola"
CHECK_MOD=$(grep "^55443322:Esteban:Morales:M:1.75:35:75:091112233:3000:MP001:" db/pacientes.txt || true)
if [[ -n "$CHECK_MOD" ]]; then
  echo -e "${VERDE}[PASS]${RESET} Test 6.2: Cuota actualizada a 3000 en el archivo"
  ((PASSED++))
else
  echo -e "${ROJO}[FAIL]${RESET} Test 6.2: Registro no se actualizó con la nueva cuota"
  ((FAILED++))
fi

# Test 7: Baja con cancelación
OUT=$(printf "2\n55443322\nn\n5\n" | bash app.sh)
assert_contains "$OUT" "Operacion cancelada" "Test 7.1: Cancelación de baja interactiva"
CHECK_AUN_ESTA=$(grep "^55443322:" db/pacientes.txt || true)
if [[ -n "$CHECK_AUN_ESTA" ]]; then
  echo -e "${VERDE}[PASS]${RESET} Test 7.2: Paciente sigue existiendo tras cancelar baja"
  ((PASSED++))
else
  echo -e "${ROJO}[FAIL]${RESET} Test 7.2: Paciente fue eliminado a pesar de cancelar"
  ((FAILED++))
fi

# Test 8: Baja confirmada
OUT=$(printf "2\n55443322\ns\n5\n" | bash app.sh)
assert_contains "$OUT" "Paciente eliminado exitosamente" "Test 8.1: Baja confirmada en consola"
CHECK_BORRADO=$(grep "^55443322:" db/pacientes.txt || true)
if [[ -z "$CHECK_BORRADO" ]]; then
  echo -e "${VERDE}[PASS]${RESET} Test 8.2: Paciente eliminado de db/pacientes.txt"
  ((PASSED++))
else
  echo -e "${ROJO}[FAIL]${RESET} Test 8.2: Paciente no fue removido del archivo"
  ((FAILED++))
fi

# Test 9: Verificar que se generó un respaldo en .bak/
BAK_COUNT=$(ls -1 .bak/ | wc -l)
if [[ $BAK_COUNT -gt 0 ]]; then
  echo -e "${VERDE}[PASS]${RESET} Test 9: Respaldo automático creado en .bak/"
  ((PASSED++))
else
  echo -e "${ROJO}[FAIL]${RESET} Test 9: No se encontraron respaldos en .bak/"
  ((FAILED++))
fi

# Restaurar estado original de las bases de datos para no dejar basura de pruebas
rm -rf db
mv db_e2e_backup db
rm -rf .bak
if [[ -d .bak_e2e_backup ]]; then
  mv .bak_e2e_backup .bak
fi

echo "================================"
echo -e "RESULTADOS: ${VERDE}${PASSED} PASARON${RESET} | ${ROJO}${FAILED} FALLARON${RESET}"
echo "================================"

if [[ $FAILED -eq 0 ]]; then
  exit 0
else
  exit 1
fi
