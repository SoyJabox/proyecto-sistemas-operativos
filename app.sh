#!/bin/bash
echo ---------------- GESTION DE PACIENTES ----------------
echo "Integrantes: Adrian Fros, Javier Miranda"

## Archivos de la base de datos
argumento=$1                                   # Opcion pasada por comando (ej: --help o numero)
archivo_pacientes="./db/pacientes.txt"         # Archivo donde se guardan los pacientes
archivo_medicos="./db/medicos.txt"             # Archivo con la lista de medicos

## Funciones de inicializacion y ayuda

inicializar_archivos() {
  # Crea la carpeta db y los archivos de texto si todavia no existen
  mkdir -p "./db"
  if [[ ! -f "$archivo_medicos" ]]; then
    echo -e "MP001:Roberto:Alvarez\nMP002:Patricia:Morales\nMP003:Fernando:Castro\nMP004:Gabriela:Rios" >"$archivo_medicos"
  fi
  if [[ ! -f "$archivo_pacientes" ]]; then
    echo -e "12345678:Juan:Perez:099123456:1500:MP001:2020-03-15\n23456789:Maria:Gonzalez:098234567:1500:MP002:2019-07-22" >"$archivo_pacientes"
  fi
}

mostrar_ayuda() {
  cat <<'EOF'
SISTEMA DE GESTION DE PACIENTES

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

guardar_paciente() {
  # Parametros: ci, nombre, apellido, telefono, cuota, matricula_medico, fecha_ingreso
  local ci=$1
  local nombre=$2
  local apellido=$3
  local telefono=$4
  local cuota=$5
  local matricula_medico=$6
  local fecha_ingreso=$7

  # Armamos la linea separada por dos puntos
  local linea="${ci}:${nombre}:${apellido}:${telefono}:${cuota}:${matricula_medico}:${fecha_ingreso}"

  # Guardamos la linea al final del archivo
  echo "$linea" >>"$archivo_pacientes"

  echo "Paciente con CI ${ci} guardado con exito."
}

crear_respaldo() {
  local archivo_origen="$1"
  local fecha_hora=$(date +"%Y%m%d_%H%M%S")
  local nombre_archivo=$(basename "$archivo_origen")
  local carpeta_respaldos="./.bak"
  local nombre_respaldo="${nombre_archivo}.backup.${fecha_hora}"

  mkdir -p "$carpeta_respaldos"
  cp "$archivo_origen" "${carpeta_respaldos}/${nombre_respaldo}"

  echo "Respaldo creado: ${carpeta_respaldos}/${nombre_respaldo}"
}

## Operaciones del sistema

alta_paciente() {
  echo "--- Alta de paciente ---"
  read -p "Ingresa la CI del paciente (7 a 9 digitos, o 0 para volver): " ci

  # Si el usuario ingresa 0 vuelve al menu
  if [[ "$ci" == "0" ]]; then
    echo "Volviendo al menu..."
    return
  fi

  # Validamos que la cedula tenga entre 7 y 9 digitos numericos
  if [[ "$ci" =~ ^[0-9]{7,9}$ ]]; then
    echo "CI valida: $ci"
  else
    echo "Error: Debes ingresar entre 7 y 9 digitos numericos o '0' para volver."
    return
  fi

  # Verificamos si la cedula ya existe en el archivo
  if grep -q "^$ci:" "$archivo_pacientes"; then
    echo "Error: El paciente con CI $ci ya esta registrado."
    return
  fi

  read -p "Por favor, ingrese el nombre: " nombre
  read -p "Por favor, ingrese el apellido: " apellido
  read -p "Por favor, ingrese el telefono: " telefono

  # Validamos que la cuota sea un numero
  read -p "Por favor, ingrese la cuota social mensual: " cuota
  if [[ ! "$cuota" =~ ^[0-9]+$ ]]; then
    echo "Error: La cuota debe ser un valor numerico."
    return
  fi

  # Mostramos los medicos y validamos la matricula
  echo "Medicos disponibles:"
  cat "$archivo_medicos"
  read -p "Por favor, ingrese la matricula del medico de cabecera: " matricula
  if ! grep -q "^$matricula:" "$archivo_medicos"; then
    echo "Error: La matricula $matricula no existe en la lista de medicos."
    return
  fi

  local fecha_hoy=$(date +"%Y-%m-%d")
  read -p "Por favor, ingrese la fecha de ingreso [Enter para $fecha_hoy]: " fecha_ingreso
  fecha_ingreso=${fecha_ingreso:-$fecha_hoy}

  # Hacemos un respaldo del archivo antes de agregar
  crear_respaldo "$archivo_pacientes"

  # Guardamos el paciente
  guardar_paciente "$ci" "$nombre" "$apellido" "$telefono" "$cuota" "$matricula" "$fecha_ingreso"

  echo "Paciente añadido exitosamente."
}

baja_paciente() {
  echo "--- Baja de paciente ---"
  read -p "Ingrese la CI del paciente a eliminar: " ci

  # Verificar si la cedula existe
  if ! grep -q "^$ci:" "$archivo_pacientes"; then
    echo "No se encontro ningun paciente con CI $ci."
    return
  fi

  # Mostrar el registro encontrado
  echo "Registro encontrado:"
  grep "^$ci:" "$archivo_pacientes"

  # Pedir confirmacion
  read -p "¿Esta seguro que desea eliminar este paciente? (s/n): " confirmacion
  if [[ "$confirmacion" != "s" && "$confirmacion" != "S" ]]; then
    echo "Operacion cancelada."
    return
  fi

  # Respaldo antes de eliminar
  crear_respaldo "$archivo_pacientes"

  # Eliminamos la linea con sed
  sed -i "/^$ci:/d" "$archivo_pacientes"

  echo "Paciente eliminado exitosamente."
}

modificar_paciente() {
  echo "--- Modificar registro de paciente ---"
  read -p "Ingrese la CI del paciente a modificar: " ci

  # Verificar si la cedula existe
  if ! grep -q "^$ci:" "$archivo_pacientes"; then
    echo "No se encontro ningun paciente con CI $ci."
    return
  fi

  # Obtener la linea actual y sus campos
  local linea=$(grep "^$ci:" "$archivo_pacientes")
  echo "Registro actual: $linea"

  local ci_actual=$(echo "$linea" | cut -d':' -f1)
  local nombre_actual=$(echo "$linea" | cut -d':' -f2)
  local apellido_actual=$(echo "$linea" | cut -d':' -f3)
  local telefono_actual=$(echo "$linea" | cut -d':' -f4)
  local cuota_actual=$(echo "$linea" | cut -d':' -f5)
  local matricula_actual=$(echo "$linea" | cut -d':' -f6)
  local fecha_actual=$(echo "$linea" | cut -d':' -f7)

  echo "¿Que campo desea modificar?"
  echo "1. Nombre"
  echo "2. Apellido"
  echo "3. Telefono"
  echo "4. Cuota Social Mensual"
  echo "5. Matricula del Medico de Cabecera"
  echo "6. Fecha de Ingreso"
  read -p "Opcion: " campo_elegido

  case $campo_elegido in
  1)
    read -p "Por favor, ingrese el nuevo nombre: " nombre_actual
    ;;
  2)
    read -p "Por favor, ingrese el nuevo apellido: " apellido_actual
    ;;
  3)
    read -p "Por favor, ingrese el nuevo telefono: " telefono_actual
    ;;
  4)
    read -p "Por favor, ingrese la nueva cuota social mensual: " nueva_cuota
    if [[ ! "$nueva_cuota" =~ ^[0-9]+$ ]]; then
      echo "Error: La cuota debe ser un numero."
      return
    fi
    cuota_actual=$nueva_cuota
    ;;
  5)
    echo "Medicos disponibles:"
    cat "$archivo_medicos"
    read -p "Por favor, ingrese la nueva matricula del medico: " nueva_matricula
    if ! grep -q "^$nueva_matricula:" "$archivo_medicos"; then
      echo "Error: Matricula de medico inexistente."
      return
    fi
    matricula_actual=$nueva_matricula
    ;;
  6)
    read -p "Por favor, ingrese la nueva fecha de ingreso (YYYY-MM-DD): " fecha_actual
    ;;
  *)
    echo "Opcion no valida."
    return
    ;;
  esac

  local linea_modificada="${ci_actual}:${nombre_actual}:${apellido_actual}:${telefono_actual}:${cuota_actual}:${matricula_actual}:${fecha_actual}"

  # Respaldo antes de modificar
  crear_respaldo "$archivo_pacientes"

  # Reemplazar la linea en el archivo
  sed -i "/^$ci:/c\\$linea_modificada" "$archivo_pacientes"

  echo "Registro modificado exitosamente."
}

buscar_por_ci() {
  read -p "Ingrese la CI del paciente: " ci
  if grep -q "^$ci:" "$archivo_pacientes"; then
    grep "^$ci:" "$archivo_pacientes"
  else
    echo "No se encontro ningun paciente con CI $ci."
  fi
}

consultas() {
  echo "--- Consultar registros de paciente ---"
  echo "
        PRESIONA 1: NOMBRE Y APELLIDO DE PACIENTES DE UN MEDICO
        PRESIONA 2: CUOTA DE UN SOCIO DETERMINADO
        PRESIONA 3: MEDICO DE UN PACIENTE
        PRESIONA 4: TOTAL MENSUAL DE INGRESO POR CUOTA SOCIAL
        PRESIONA 5: CANTIDAD DE PACIENTES POR MEDICO (CONSULTA EXTRA)
        PRESIONA 6: MOSTRAR TODOS LOS REGISTROS / BUSCAR POR CI
        "
  read -p "Opcion: " opcion_consulta

  case $opcion_consulta in
  1)
    cat "$archivo_medicos"
    read -p "Ingrese matricula del medico: " matricula_buscada
    echo "Pacientes del medico $matricula_buscada:"
    while IFS=':' read -r p_ci p_nombre p_apellido p_telefono p_cuota p_matricula p_fecha; do
      if [[ "$p_matricula" == "$matricula_buscada" ]]; then
        echo "$p_nombre $p_apellido"
      fi
    done <"$archivo_pacientes"
    ;;
  2)
    read -p "Ingrese la CI del socio: " ci_buscada
    if grep -q "^$ci_buscada:" "$archivo_pacientes"; then
      local linea=$(grep "^$ci_buscada:" "$archivo_pacientes")
      local nombre=$(echo "$linea" | cut -d':' -f2)
      local apellido=$(echo "$linea" | cut -d':' -f3)
      local cuota=$(echo "$linea" | cut -d':' -f5)
      echo "Socio: $nombre $apellido | Cuota mensual: \$$cuota"
    else
      echo "No se encontro ningun socio con CI $ci_buscada."
    fi
    ;;
  3)
    read -p "Ingrese la CI del paciente: " ci_buscada
    if grep -q "^$ci_buscada:" "$archivo_pacientes"; then
      local linea=$(grep "^$ci_buscada:" "$archivo_pacientes")
      local nombre_pac=$(echo "$linea" | cut -d':' -f2)
      local apellido_pac=$(echo "$linea" | cut -d':' -f3)
      local matricula_med=$(echo "$linea" | cut -d':' -f6)
      local linea_med=$(grep "^$matricula_med:" "$archivo_medicos")
      local nombre_med=$(echo "$linea_med" | cut -d':' -f2)
      local apellido_med=$(echo "$linea_med" | cut -d':' -f3)
      echo "Paciente: $nombre_pac $apellido_pac | Medico de cabecera: $nombre_med $apellido_med (Matricula: $matricula_med)"
    else
      echo "No se encontro ningun paciente con CI $ci_buscada."
    fi
    ;;
  4)
    local total=0
    while IFS=':' read -r p_ci p_nombre p_apellido p_telefono p_cuota p_matricula p_fecha; do
      if [[ "$p_cuota" =~ ^[0-9]+$ ]]; then
        total=$((total + p_cuota))
      fi
    done <"$archivo_pacientes"
    echo "Total mensual de ingreso de la mutualista por cuotas sociales: \$$total"
    ;;
  5)
    echo "Cantidad de pacientes asignados por medico:"
    while IFS=':' read -r m_matricula m_nombre m_apellido; do
      local contador=0
      while IFS=':' read -r p_ci p_nombre p_apellido p_telefono p_cuota p_matricula p_fecha; do
        if [[ "$p_matricula" == "$m_matricula" ]]; then
          contador=$((contador + 1))
        fi
      done <"$archivo_pacientes"
      echo "Dr/a. $m_nombre $m_apellido (Mat. $m_matricula): $contador paciente(s)"
    done <"$archivo_medicos"
    ;;
  6)
    echo "Presione 1 para mostrar todos los registros o 2 para buscar por CI:"
    read -p "Opcion: " sub_opcion
    if [[ $sub_opcion == 1 ]]; then
      cat "$archivo_pacientes"
    else
      buscar_por_ci
    fi
    ;;
  *)
    echo "Opcion no valida."
    ;;
  esac
}

menu_principal() {
  local opcion_usuario=$1

  # Bucle principal: solo se sale eligiendo la opcion 5
  while true; do
    if [[ -z "$opcion_usuario" || "$opcion_usuario" -lt 1 || "$opcion_usuario" -gt 5 ]] 2>/dev/null; then
      echo ""
      echo "Hola $(whoami), ¿Que quieres hacer?"
      echo "
        PRESIONA 1: ALTA DE PACIENTE
        PRESIONA 2: BAJA DE PACIENTE
        PRESIONA 3: MODIFICAR UN REGISTRO
        PRESIONA 4: CONSULTAS
        PRESIONA 5: SALIR
        "
      read -p "Decision: " opcion_usuario
    fi

    case $opcion_usuario in
    1)
      alta_paciente
      ;;
    2)
      baja_paciente
      ;;
    3)
      modificar_paciente
      ;;
    4)
      consultas
      ;;
    5)
      echo "Saliendo del sistema..."
      exit 0
      ;;
    *)
      echo "Por favor, siga las instrucciones"
      ;;
    esac

    # Limpiamos opcion_usuario para que en la siguiente vuelta muestre el menu
    opcion_usuario=""
  done
}

### Inicio del programa
if [[ $argumento == '--help' || $argumento == '-h' || $argumento == 'help' || $argumento == '-help' ]]; then
  mostrar_ayuda
else
  inicializar_archivos
  menu_principal "$argumento"
fi
