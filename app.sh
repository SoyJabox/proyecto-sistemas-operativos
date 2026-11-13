#!/bin/bash
echo ---------------- GESTION DE PACIENTES ----------------

## Variables Globales
ARG=$1                      # Qué opción pidió el usuario (1-5 o --help)
BD="./db/pacientes-min.txt" # Archivo donde se guardan los datos de los pacientes

## Funciones logicas

function_guardar_paciente() {
  # Recibe: DNI, nombre, teléfono, cuota, matrícula del médico
  local DNI=$1
  local NOM=$2
  # Transformamos los espacios en NOM a dos puntos para mantener el formato delimitado
  local NOM=${NOM// /:}
  local TEL=$3
  local CSM=$4
  local MED_MAT=$5

  # Armamos la línea en formato: DNI:nombre:telefono:costo:medico
  local linea="${DNI}:${NOM}:${TEL}:${CSM}:${MED_MAT}"

  # Agregamos la línea al archivo de base de datos (crea el archivo si no existe)
  echo "$linea" >>"$BD"

  echo "Paciente ${DNI} guardado exitosamente en la base de datos."
}

function_backup() {
  # Recibe la ruta de la base de datos
  local BD="$1"
  local FECHA=$(date +"%Y%m%d_%H%M%S")                 # Fecha y hora actual para el nombre del backup
  local NOMBRE_ARCHIVO=$(basename "$BD")               # Obtiene solo el nombre del archivo (sin la ruta completa)
  local NOMBRE_BAK="${NOMBRE_ARCHIVO}.backup.${FECHA}" # Nombre final: pacientes-min.txt.backup.20261113_092142
  local BACKUP_DIR="./.bak"                            # Carpeta donde se guardarán los respaldos

  # Creamos la carpeta .bak si aún no existe
  mkdir -p "$BACKUP_DIR"

  # Copiamos la base de datos a la carpeta .bak con el nombre fecheado
  cp "$BD" "${BACKUP_DIR}/${NOMBRE_BAK}"

  echo "Backup creado: ${BACKUP_DIR}/${NOMBRE_BAK}"
}

## Funciones principales

function_alta() {
  # DNI que el usuario ingresará
  echo --- Alta de paciente ---
  read -p "Ingresa el DNI del paciente (ó 0 para salir): " DNI

  # 1. Primero verificamos si el usuario quiere salir (DNI 0)
  if [[ "$DNI" -eq 0 ]]; then
    echo "Saliendo del script..."
    exit 0
  fi

  # 2. Validamos que el DNI tenga exactamente 9 dígitos (solo números, sin letras ni espacios)
  if [[ "$DNI" =~ ^[0-9]{9}$ ]]; then
    echo "Input válido: $DNI"
  else
    echo "Error: Debes ingresar exactamente 9 dígitos o solo '0' para salir."
    exit 1
  fi

  # 3. Buscamos en la base de datos si ese DNI ya está registrado
  if grep -q "^$DNI:" "$BD"; then
    echo "Error: El paciente con DNI $DNI ya está registrado."
    exit 0
  fi

  echo "No coinciden las referencias" # Significa que el DNI es nuevo y puede guardarse

  # Pedimos los datos del paciente
  read -p "Por favor, ingrese el primero nombre y primer apellido: " NOM
  read -p "Por favor, ingrese el telefono: " TEL
  read -p "Por favor, ingrese la cuota social mensual: " CSM
  read -p "Por favor, ingrese la matricula del medico de cabecera: " MED_MAT

  # Hacemos un respaldo antes de guardar (con fecha y hora actual)
  function_backup "$BD"

  # Guardamos el nuevo paciente en la base de datos
  function_guardar_paciente "$DNI" "$NOM" "$TEL" "$CSM" "$MED_MAT"

  echo "Paciente añadido exitosamente."
}

function_baja() {
  echo Baja de paciente
  read -p "Ingrese el DNI del paciente a eliminar: " DNI

  # Verificar si el DNI existe en la base de datos
  if ! grep -q "^$DNI:" "$BD"; then
    echo "No se encontró ningún paciente con DNI $DNI."
    return
  fi

  # Mostrar el registro actual
  echo "Registro actual:"
  grep "^$DNI:" "$BD"

  # Realizar el respaldo antes de eliminar
  local FECHA=$(date +"%Y%m%d_%H%M%S")
  local NOMBRE_ARCHIVO=$(basename "$BD")
  local NOMBRE_BAK="deleted_${FECHA}.txt.bak"
  local BACKUP_DIR="./.bak"

  # Crear la carpeta .bak si aún no existe
  mkdir -p "$BACKUP_DIR"

  # Copiar la base de datos a la carpeta .bak con el nombre fecheado
  cp "$BD" "${BACKUP_DIR}/${NOMBRE_BAK}"

  echo "Backup creado: ${BACKUP_DIR}/${NOMBRE_BAK}"

  # Eliminar el registro del paciente
  sed -i "/^$DNI:/d" "$BD"

  echo "Paciente eliminado exitosamente."
}

function_modificar() {
  echo Modificar registro de paciente
  read -p "Ingrese el DNI del paciente a modificar: " DNI

  # Verificar si el DNI existe en la base de datos
  if ! grep -q "^$DNI:" "$BD"; then
    echo "No se encontró ningún paciente con DNI $DNI."
    return
  fi

  # Mostrar el registro actual
  echo "Registro actual:"
  grep "^$DNI:" "$BD"

  # Solicitar qué campo desea modificar
  echo "¿Qué campo desea modificar?"
  echo "1. Nombre y Apellido"
  echo "2. Teléfono"
  echo "3. Cuota Social Mensual"
  echo "4. Matrícula del Médico de Cabecera"
  read -p "Opción: " FIELD

  # Solicitar el nuevo valor para el campo seleccionado
  case $FIELD in
  1)
    read -p "Por favor, ingrese el nuevo nombre y apellido: " NOM
    NEW_VALUE=$NOM
    ;;
  2)
    read -p "Por favor, ingrese el nuevo teléfono: " TEL
    NEW_VALUE=$TEL
    ;;
  3)
    read -p "Por favor, ingrese la nueva cuota social mensual: " CSM
    NEW_VALUE=$CSM
    ;;
  4)
    read -p "Por favor, ingrese la nueva matrícula del médico de cabecera: " MED_MAT
    NEW_VALUE=$MED_MAT
    ;;
  *)
    echo "Opción no válida."
    return
    ;;
  esac

  # Crear la nueva línea con el campo modificado
  local linea=$(grep "^$DNI:" "$BD")
  local OLD_VALUE=$(echo $linea | cut -d':' -f$((FIELD + 1)))
  local nueva_linea=$(echo $linea | sed "s/$OLD_VALUE/$NEW_VALUE/")

  # Realizar el respaldo antes de modificar
  function_backup "$BD"

  # Reemplazar la línea vieja con la nueva en el archivo de base de datos
  sed -i "/^$DNI:/c\\$nueva_linea" "$BD"

  echo "Campo modificado exitosamente."
}

function_consultar() {
  echo --- Consultar registros de paciente ---
  read -p "Presione 1 para todos ó 2 para busqueda parametrada: " USER_INPUT
  if [[ $USER_INPUT == 1 ]]; then
    cat $BD
  else
    echo buscando paciente...
    sleep 2
  fi
}

function_buscar_por_dni() {
  echo "Ingrese el DNI del paciente a buscar:"
  read -p "DNI: " DNI
  if grep -q "^$DNI:" "$BD"; then
    grep "^$DNI:" "$BD"
  else
    echo "No se encontró ningún paciente con DNI $DNI."
  fi
}

main() {
  local USER_INPUT=$1
  # Si no hay argumento o es inválido, mostramos el menú
  if [[ -z "$USER_INPUT" || "$USER_INPUT" -lt 1 || "$USER_INPUT" -gt 5 ]]; then
    echo "Hola $(whoami), ¿Qué quieres hacer?"
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
    # Llamamos a la función de alta pasando el DNI ingresado
    function_alta
    ;;
  2)
    function_baja
    ;;
  3)
    function_modificar
    ;;
  4)
    echo "Presione 1 para mostrar todos los registros ó 2 para buscar por DNI:"
    read -p "Opción: " USER_INPUT
    if [[ $USER_INPUT == 1 ]]; then
      cat $BD
    else
      function_buscar_por_dni
    fi
    ;;
  5)
    echo Salir
    ;;
  *)
    echo Por favor, siga las instrucciones
    ;;
  esac
}

### Inicio de programa
if [[ $ARG == '--help' || $ARG == '-h' || $ARG == 'help' || $ARG == '-help' ]]; then
  ### Comando HELP: muestra el manual de uso
  echo "--------------------------------------------------------------"
  echo "Este es el manual de uso de la aplicación de gestión de pacientes."
  echo "--------------------------------------------------------------"
  echo "Comandos disponibles:"
  echo "  --help, -h, help, -help: Muestra este manual de ayuda."
  echo "  1: Alta de paciente - Agrega un nuevo paciente."
  echo "  2: Baja de paciente - Elimina un paciente y crea un respaldo."
  echo "  3: Modificar un registro - Cambia los datos de un paciente existente."
  echo "  4: Consultas - Muestra todos los registros o busca por DNI."
  echo "  5: Salir - Sale de la aplicación."
  echo "--------------------------------------------------------------"
  echo "Para usar cada comando, sigue las instrucciones que aparecen en el menú."
  echo "--------------------------------------------------------------"
  sleep 2
else
  # function_alta "$ARG" es para agilizar el testing
  main "$ARG"
fi
