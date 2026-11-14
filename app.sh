#!/bin/bash
echo ---------------- GESTION DE PACIENTES ----------------
echo "Integrantes: Adrian Fros, Javier Miranda"

## Variables Globales
ARG=$1                        # Qué opción pidió el usuario (1-5 o --help)
BD="./db/pacientes.txt"       # Archivo donde se guardan los datos de los pacientes
BD_MEDICOS="./db/medicos.txt" # Archivo estático con la lista de médicos

## Funciones logicas

function_init() {
  # Crea la carpeta db y archivos con datos de prueba si no existen
  mkdir -p "./db"
  if [[ ! -f "$BD_MEDICOS" ]]; then
    echo -e "1001:Carlos:Gomez\n1002:Laura:Fernandez\n1003:Martin:Silva" >"$BD_MEDICOS"
  fi
  if [[ ! -f "$BD" ]]; then
    echo -e "45123456:Juan:Perez:099111222:2500:1001:2024-03-15\n51234567:Ana:Rodriguez:098333444:3200:1002:2025-01-10" >"$BD"
  fi
}

function_help() {
  cat <<'EOF'
SISTEMA DE GESTION DE PACIENTES - *IA*

USO:
  bash app.sh [OPCION]

DESCRIPCION:
  Herramienta de consola para administrar el padron de socios, asignacion de
  medicos de cabecera y control de cuotas sociales sobre archivos de texto.

OPCIONES DISPONIBLES:
  (sin argumentos)      Inicia el menu interactivo principal.
  1                     Alta de paciente - Agrega un nuevo socio.
  2                     Baja de paciente - Elimina un socio y crea un respaldo.
  3                     Modificar un registro - Cambia datos de un socio existente.
  4                     Consultas - Reportes por medico, cuota, socio e ingresos.
  5                     Salir - Finaliza la ejecucion de la aplicacion.
  -h, --help            Muestra este manual de ayuda y sale.

ESTRUCTURA DE ARCHIVOS (Delimitador ':'):
  ./db/pacientes.txt    CI:NOMBRE:APELLIDO:TELEFONO:CUOTA_SOCIAL:MATRICULA_MEDICO:FECHA_INGRESO
  ./db/medicos.txt      MATRICULA:NOMBRE:APELLIDO

EJEMPLOS:
  bash app.sh           # Inicia el menu interactivo
  bash app.sh 1         # Entra directo al alta de paciente
  bash app.sh --help    # Muestra esta documentacion
EOF
  exit 0
}

function_guardar_paciente() {
  # Recibe: CI, nombre y apellido, teléfono, cuota, matrícula del médico, fecha de ingreso
  local DNI=$1
  local NOM=$2
  # Transformamos los espacios en NOM a dos puntos para mantener el formato NOMBRE:APELLIDO
  local NOM=${NOM// /:} ## Apoyado de la IA
  local TEL=$3
  local CSM=$4
  local MED_MAT=$5
  local FECHA_ING=$6

  # Armamos la línea en formato: CI:NOMBRE:APELLIDO:TELEFONO:CUOTA:MATRICULA:FECHA_INGRESO
  local linea="${DNI}:${NOM}:${TEL}:${CSM}:${MED_MAT}:${FECHA_ING}"

  # Agregamos la línea al archivo de base de datos
  echo "$linea" >>"$BD"

  echo "Paciente ${DNI} guardado exitosamente en la base de datos."
}

function_backup() {
  # Recibe la ruta de la base de datos
  local BD="$1"
  local FECHA=$(date +"%Y%m%d_%H%M%S")                 # Fecha y hora actual para el nombre del backup
  local NOMBRE_ARCHIVO=$(basename "$BD")               # Obtiene solo el nombre del archivo
  local NOMBRE_BAK="${NOMBRE_ARCHIVO}.backup.${FECHA}" # Nombre final con fecha y hora
  local BACKUP_DIR="./.bak"                            # Carpeta donde se guardarán los respaldos

  # Creamos la carpeta .bak si aún no existe
  mkdir -p "$BACKUP_DIR"

  # Copiamos la base de datos a la carpeta .bak con el nombre fecheado
  cp "$BD" "${BACKUP_DIR}/${NOMBRE_BAK}"

  echo "Backup creado: ${BACKUP_DIR}/${NOMBRE_BAK}"
}

## Funciones principales

function_alta() {
  echo "--- Alta de paciente ---"
  read -p "Ingresa la CI del paciente (8 digitos, o 0 para volver): " DNI

  # 1. Primero verificamos si el usuario quiere volver (0)
  if [[ "$DNI" == "0" ]]; then
    echo "Volviendo al menu..."
    return
  fi

  # 2. Validamos que la CI tenga exactamente 8 dígitos (solo números)
  if [[ "$DNI" =~ ^[0-9]{8}$ ]]; then
    echo "Input valido: $DNI"
  else
    echo "Error: Debes ingresar exactamente 8 digitos o solo '0' para volver."
    return
  fi

  # 3. Buscamos en la base de datos si esa CI ya está registrada
  if grep -q "^$DNI:" "$BD"; then
    echo "Error: El paciente con CI $DNI ya esta registrado."
    return
  fi

  # Pedimos los datos del paciente
  read -p "Por favor, ingrese el primer nombre y primer apellido: " NOM
  read -p "Por favor, ingrese el telefono: " TEL
  read -p "Por favor, ingrese la cuota social mensual: " CSM

  # Mostramos médicos disponibles y validamos que la matrícula exista
  echo "Medicos disponibles:"
  cat "$BD_MEDICOS"
  read -p "Por favor, ingrese la matricula del medico de cabecera: " MED_MAT
  if ! grep -q "^$MED_MAT:" "$BD_MEDICOS"; then
    echo "Error: La matricula $MED_MAT no existe en la lista de medicos."
    return
  fi

  local HOY=$(date +"%Y-%m-%d")
  read -p "Por favor, ingrese la fecha de ingreso [Enter para $HOY]: " FECHA_ING
  FECHA_ING=${FECHA_ING:-$HOY}

  # Hacemos un respaldo antes de guardar
  function_backup "$BD"

  # Guardamos el nuevo paciente en la base de datos
  function_guardar_paciente "$DNI" "$NOM" "$TEL" "$CSM" "$MED_MAT" "$FECHA_ING"

  echo "Paciente añadido exitosamente."
}

function_baja() {
  echo "--- Baja de paciente ---"
  read -p "Ingrese la CI del paciente a eliminar: " DNI

  # Verificar si la CI existe en la base de datos
  if ! grep -q "^$DNI:" "$BD"; then
    echo "No se encontro ningun paciente con CI $DNI."
    return
  fi

  # Mostrar el registro actual
  echo "Registro actual:"
  grep "^$DNI:" "$BD"

  # Realizar el respaldo antes de eliminar
  local FECHA=$(date +"%Y%m%d_%H%M%S")
  local NOMBRE_BAK="deleted_${FECHA}.txt.bak"
  local BACKUP_DIR="./.bak"

  mkdir -p "$BACKUP_DIR"
  cp "$BD" "${BACKUP_DIR}/${NOMBRE_BAK}"
  echo "Backup creado: ${BACKUP_DIR}/${NOMBRE_BAK}"

  # Eliminar el registro del paciente
  sed -i "/^$DNI:/d" "$BD"

  echo "Paciente eliminado exitosamente."
}

function_modificar() {
  echo "--- Modificar registro de paciente ---"
  read -p "Ingrese la CI del paciente a modificar: " DNI

  # Verificar si la CI existe en la base de datos
  if ! grep -q "^$DNI:" "$BD"; then
    echo "No se encontro ningun paciente con CI $DNI."
    return
  fi

  # Mostrar el registro actual y separar sus campos
  local linea=$(grep "^$DNI:" "$BD")
  echo "Registro actual: $linea"

  # Prefijo F -> Field -> Campos
  local F_CI=$(echo "$linea" | cut -d':' -f1)
  local F_NOM=$(echo "$linea" | cut -d':' -f2)
  local F_APE=$(echo "$linea" | cut -d':' -f3)
  local F_TEL=$(echo "$linea" | cut -d':' -f4)
  local F_CSM=$(echo "$linea" | cut -d':' -f5)
  local F_MED=$(echo "$linea" | cut -d':' -f6)
  local F_FEC=$(echo "$linea" | cut -d':' -f7)

  # Solicitar qué campo desea modificar
  echo "¿Que campo desea modificar?"
  echo "1. Nombre y Apellido"
  echo "2. Telefono"
  echo "3. Cuota Social Mensual"
  echo "4. Matricula del Medico de Cabecera"
  echo "5. Fecha de Ingreso"
  read -p "Opcion: " FIELD

  case $FIELD in
  1)
    read -p "Por favor, ingrese el nuevo nombre y apellido: " NOM
    F_NOM=$(echo "$NOM" | cut -d' ' -f1) # Capturamos el nombre, antes del espacio
    F_APE=$(echo "$NOM" | cut -d' ' -f2) # Capturamos el apellido, despues del espacio
    ;;
  2)
    read -p "Por favor, ingrese el nuevo telefono: " F_TEL
    ;;
  3)
    read -p "Por favor, ingrese la nueva cuota social mensual: " F_CSM
    ;;
  4)
    echo "Medicos disponibles:"
    cat "$BD_MEDICOS"
    read -p "Por favor, ingrese la nueva matricula del medico: " NEW_MED
    if ! grep -q "^$NEW_MED:" "$BD_MEDICOS"; then
      echo "Error: Matricula de medico inexistente."
      return
    fi
    F_MED=$NEW_MED
    ;;
  5)
    read -p "Por favor, ingrese la nueva fecha de ingreso (YYYY-MM-DD): " F_FEC
    ;;
  *)
    echo "Opcion no valida."
    return
    ;;
  esac

  local nueva_linea="${F_CI}:${F_NOM}:${F_APE}:${F_TEL}:${F_CSM}:${F_MED}:${F_FEC}"

  # Realizar el respaldo antes de modificar
  function_backup "$BD"

  # Reemplazar la línea vieja con la nueva en el archivo de base de datos
  sed -i "/^$DNI:/c\\$nueva_linea" "$BD"

  echo "Campo modificado exitosamente."
}

function_buscar_por_dni() {
  read -p "Ingrese la CI del paciente: " DNI
  if grep -q "^$DNI:" "$BD"; then
    grep "^$DNI:" "$BD"
  else
    echo "No se encontro ningun paciente con CI $DNI."
  fi
}

function_consultar() {
  echo "--- Consultar registros de paciente ---"
  echo "
        PRESIONA 1: NOMBRE Y APELLIDO DE PACIENTES DE UN MEDICO
        PRESIONA 2: CUOTA DE UN SOCIO DETERMINADO
        PRESIONA 3: MEDICO DE UN PACIENTE
        PRESIONA 4: TOTAL MENSUAL DE INGRESO POR CUOTA SOCIAL
        PRESIONA 5: CANTIDAD DE PACIENTES POR MEDICO (CONSULTA EXTRA)
        PRESIONA 6: MOSTRAR TODOS LOS REGISTROS / BUSCAR POR CI
        "
  read -p "Opcion: " CONS_INPUT

  case $CONS_INPUT in
  1)
    cat "$BD_MEDICOS"
    read -p "Ingrese matricula del medico: " MAT
    echo "Pacientes del medico $MAT:"
    awk -F':' -v m="$MAT" '$6 == m {print $2, $3}' "$BD"
    ;;
  2)
    read -p "Ingrese la CI del socio: " DNI
    if grep -q "^$DNI:" "$BD"; then
      local linea=$(grep "^$DNI:" "$BD")
      local NOM=$(echo "$linea" | cut -d':' -f2,3 | tr ':' ' ')
      local CUOTA=$(echo "$linea" | cut -d':' -f5)
      echo "Socio: $NOM | Cuota mensual: \$$CUOTA"
    else
      echo "No se encontro ningun socio con CI $DNI."
    fi
    ;;
  3)
    read -p "Ingrese la CI del paciente: " DNI
    if grep -q "^$DNI:" "$BD"; then
      local linea=$(grep "^$DNI:" "$BD")
      local PAC=$(echo "$linea" | cut -d':' -f2,3 | tr ':' ' ')
      local MAT=$(echo "$linea" | cut -d':' -f6)
      local MED=$(grep "^$MAT:" "$BD_MEDICOS" | cut -d':' -f2,3 | tr ':' ' ')
      echo "Paciente: $PAC | Medico de cabecera: $MED (Matricula: $MAT)"
    else
      echo "No se encontro ningun paciente con CI $DNI."
    fi
    ;;
  4)
    local TOTAL=$(awk -F':' '{suma += $5} END {print suma}' "$BD")
    echo "Total mensual de ingreso de la mutualista por cuotas sociales: \$$TOTAL"
    ;;
  5)
    echo "Cantidad de pacientes asignados por medico:"
    while IFS=':' read -r MAT NOM APE; do
      local CANT=$(awk -F':' -v m="$MAT" '$6 == m {c++} END {print c+0}' "$BD")
      echo "Dr/a. $NOM $APE (Mat. $MAT): $CANT paciente(s)"
    done <"$BD_MEDICOS"
    ;;
  6)
    echo "Presione 1 para mostrar todos los registros o 2 para buscar por CI:"
    read -p "Opcion: " SUB_OP
    if [[ $SUB_OP == 1 ]]; then
      cat "$BD"
    else
      function_buscar_por_dni
    fi
    ;;
  *)
    echo "Opcion no valida."
    ;;
  esac
}

main() {
  local USER_INPUT=$1

  # Bucle principal: la única forma de salir es eligiendo la opción 5
  while true; do
    if [[ -z "$USER_INPUT" || "$USER_INPUT" -lt 1 || "$USER_INPUT" -gt 5 ]] 2>/dev/null; then
      echo ""
      echo "Hola $(whoami), ¿Que quieres hacer?"
      ### Menú de opciones
      echo "
        PRESIONA 1: ALTA DE PACIENTE
        PRESIONA 2: BAJA DE PACIENTE
        PRESIONA 3: MODIFICAR UN REGISTRO
        PRESIONA 4: CONSULTAS
        PRESIONA 5: SALIR
        "
      ### Pedimos la decisión del usuario
      read -p "Decision: " USER_INPUT
    fi

    ### Evaluamos qué opción eligió el usuario
    case $USER_INPUT in
    1)
      function_alta
      ;;
    2)
      function_baja
      ;;
    3)
      function_modificar
      ;;
    4)
      function_consultar
      ;;
    5)
      echo "Saliendo del sistema..."
      exit 0
      ;;
    *)
      echo "Por favor, siga las instrucciones"
      ;;
    esac

    # Limpiamos USER_INPUT para que vuelva a mostrar el menú en la siguiente iteración
    USER_INPUT=""
  done
}

### Inicio de programa
if [[ $ARG == '--help' || $ARG == '-h' || $ARG == 'help' || $ARG == '-help' ]]; then
  function_help
else
  function_init
  main "$ARG"
fi
