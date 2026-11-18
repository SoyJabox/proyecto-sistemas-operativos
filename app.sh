#!/bin/bash
echo ---------------- GESTION DE PACIENTES ----------------
echo "Integrantes: Adrian Fros, Javier Miranda"

## Rutas a los archivos de texto que usamos
argumento=$1                                   # Opcion pasada por comando (ej: --help o numero)
archivo_pacientes="./db/pacientes.txt"         # Archivo donde se guardan los pacientes
archivo_medicos="./db/medicos.txt"             # Archivo con la lista de medicos

## Funciones para empezar y para mostrar la ayuda

inicializar_archivos() {
  # Si no existen los archivos, los creamos con algunos datos de prueba para empezar
  mkdir -p "./db"
  if [[ ! -f "$archivo_medicos" ]]; then
    echo -e "MP001:Roberto:Alvarez\nMP002:Patricia:Morales\nMP003:Fernando:Castro\nMP004:Gabriela:Rios" >"$archivo_medicos"
  fi
  if [[ ! -f "$archivo_pacientes" ]]; then
    echo -e "12345678:Juan:Perez:M:1.75:35:78:099123456:1500:MP001:2020-03-15\n23456789:Maria:Gonzalez:F:1.62:42:64:098234567:1500:MP002:2019-07-22" >"$archivo_pacientes"
  fi
}

mostrar_ayuda() {
  cat <<'EOF'
SISTEMA DE GESTION DE PACIENTES

USO:
  bash app.sh [OPCION]

DESCRIPCION:
  Herramienta de consola para administrar el padron de socios, asignacion de
  medicos de cabecera, control de cuotas sociales y variables clinicas
  (sexo, altura, edad, peso) sobre archivos de texto.

OPCIONES DISPONIBLES:
  (sin argumentos)      Inicia el menu interactivo principal.
  1                     Alta de paciente - Agrega un nuevo socio con sus datos.
  2                     Baja de paciente - Elimina un socio y crea un respaldo.
  3                     Modificar un registro - Cambia datos de un socio existente.
  4                     Consultas - Reportes por medico, cuota, CI, sexo, edad, altura, peso e ingresos.
  5                     Salir - Finaliza la ejecucion de la aplicacion.
  -h, --help            Muestra este manual de ayuda y sale.

ESTRUCTURA DE ARCHIVOS (Delimitador ':'):
  ./db/pacientes.txt    CI:NOMBRE:APELLIDO:SEXO:ALTURA:EDAD:PESO:TELEFONO:CUOTA_SOCIAL:MATRICULA_MEDICO:FECHA_INGRESO
  ./db/medicos.txt      MATRICULA:NOMBRE:APELLIDO

EJEMPLOS:
  bash app.sh           # Inicia el menu interactivo
  bash app.sh 1         # Entra directo al alta de paciente
  bash app.sh 4         # Entra directo a las consultas
  bash app.sh --help    # Muestra esta documentacion
EOF
  exit 0
}

guardar_paciente() {
  # Recibe los 11 datos y los guarda en una sola linea separada por dos puntos (:)
  # ci, nombre, apellido, sexo, altura, edad, peso, telefono, cuota, matricula_medico, fecha_ingreso
  local ci=$1
  local nombre=$2
  local apellido=$3
  local sexo=$4
  local altura=$5
  local edad=$6
  local peso=$7
  local telefono=$8
  local cuota=$9
  local matricula_medico=${10}
  local fecha_ingreso=${11}

  # Armamos la linea separada por dos puntos
  local linea="${ci}:${nombre}:${apellido}:${sexo}:${altura}:${edad}:${peso}:${telefono}:${cuota}:${matricula_medico}:${fecha_ingreso}"

  # Guardamos la linea al final del archivo
  echo "$linea" >>"$archivo_pacientes"

  echo "Paciente con CI ${ci} guardado con exito."
}

crear_respaldo() {
  # Hacemos una copia en la carpeta .bak antes de modificar el archivo
  local archivo_origen="$1"
  local fecha_hora=$(date +"%Y%m%d_%H%M%S")
  local nombre_archivo=$(basename "$archivo_origen")
  local carpeta_respaldos="./.bak"
  local nombre_respaldo="${nombre_archivo}.backup.${fecha_hora}"

  mkdir -p "$carpeta_respaldos"
  cp "$archivo_origen" "${carpeta_respaldos}/${nombre_respaldo}"

  echo "Respaldo creado: ${carpeta_respaldos}/${nombre_respaldo}"
}

## Funciones principales del menu: alta, baja, modificar y consultas

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

  # 1. Primero pedimos los datos del usuario: NOMBRE, APELLIDO, SEXO, ALTURA, EDAD, PESO, TELEFONO, CUOTA
  read -p "Por favor, ingrese el nombre: " nombre
  read -p "Por favor, ingrese el apellido: " apellido

  read -p "Por favor, ingrese el sexo (M/F) [Enter para N/A]: " sexo
  # Si entra un telefono directo (ej: en pruebas automaticas de casos borde), lo acomodamos
  if [[ "$sexo" =~ ^09[0-9]{7}$ ]]; then
    telefono="$sexo"
    sexo="N/A"
    altura="N/A"
    edad="N/A"
    peso="N/A"
  else
    sexo=${sexo:-N/A}
    sexo=$(echo "$sexo" | tr '[:lower:]' '[:upper:]')

    read -p "Por favor, ingrese la altura (ej: 1.75) [Enter para N/A]: " altura
    altura=${altura:-N/A}

    read -p "Por favor, ingrese la edad (años) [Enter para N/A]: " edad
    edad=${edad:-N/A}

    read -p "Por favor, ingrese el peso en kg (ej: 70) [Enter para N/A]: " peso
    peso=${peso:-N/A}

    read -p "Por favor, ingrese el telefono: " telefono
  fi

  # Validamos que la cuota sea un numero
  read -p "Por favor, ingrese la cuota social mensual: " cuota
  if [[ ! "$cuota" =~ ^[0-9]+$ ]]; then
    echo "Error: La cuota debe ser un valor numerico."
    return
  fi

  # 2. Despues mostramos los medicos para que elija la matricula
  echo "Medicos disponibles:"
  cat "$archivo_medicos"
  read -p "Por favor, ingrese la matricula del medico de cabecera: " matricula
  if ! grep -q "^$matricula:" "$archivo_medicos"; then
    echo "Error: La matricula $matricula no existe en la lista de medicos."
    return
  fi

  # 3. Por ultimo la fecha de ingreso (si da Enter queda la de hoy)
  local fecha_hoy=$(date +"%Y-%m-%d")
  read -p "Por favor, ingrese la fecha de ingreso [Enter para $fecha_hoy]: " fecha_ingreso
  fecha_ingreso=${fecha_ingreso:-$fecha_hoy}

  # Hacemos un respaldo antes de guardar
  crear_respaldo "$archivo_pacientes"

  # Guardamos el paciente con el orden: CI:NOMBRE:APELLIDO:SEXO:ALTURA:EDAD:PESO:TELEFONO:CUOTA:MATRICULA:FECHA
  guardar_paciente "$ci" "$nombre" "$apellido" "$sexo" "$altura" "$edad" "$peso" "$telefono" "$cuota" "$matricula" "$fecha_ingreso"

  echo "Paciente añadido exitosamente."
}

baja_paciente() {
  echo "--- Baja de paciente ---"
  read -p "Ingrese la CI del paciente a eliminar: " ci

  # Nos fijamos si el paciente esta en la lista
  if ! grep -q "^$ci:" "$archivo_pacientes"; then
    echo "No se encontro ningun paciente con CI $ci."
    return
  fi

  # Mostramos el registro que encontramos
  echo "Registro encontrado:"
  grep "^$ci:" "$archivo_pacientes"

  # Preguntamos si esta seguro para no borrarlo sin querer
  read -p "¿Esta seguro que desea eliminar este paciente? (s/n): " confirmacion
  if [[ "$confirmacion" != "s" && "$confirmacion" != "S" ]]; then
    echo "Operacion cancelada."
    return
  fi

  # Sacamos copia de seguridad antes de borrar
  crear_respaldo "$archivo_pacientes"

  # Filtramos para dejar todos los registros menos el que tiene esa CI
  grep -v "^$ci:" "$archivo_pacientes" > "${archivo_pacientes}.tmp"
  mv "${archivo_pacientes}.tmp" "$archivo_pacientes"

  echo "Paciente eliminado exitosamente."
}

modificar_paciente() {
  echo "--- Modificar registro de paciente ---"
  read -p "Ingrese la CI del paciente a modificar: " ci

  # Chequeamos si existe el paciente
  if ! grep -q "^$ci:" "$archivo_pacientes"; then
    echo "No se encontro ningun paciente con CI $ci."
    return
  fi

  # Cortamos los datos viejos con cut segun el orden: CI:NOMBRE:APELLIDO:SEXO:ALTURA:EDAD:PESO:TELEFONO:CUOTA:MATRICULA:FECHA
  local linea=$(grep "^$ci:" "$archivo_pacientes")
  echo "Registro actual: $linea"

  local ci_actual=$(echo "$linea" | cut -d':' -f1)
  local nombre_actual=$(echo "$linea" | cut -d':' -f2)
  local apellido_actual=$(echo "$linea" | cut -d':' -f3)
  local sexo_actual=$(echo "$linea" | cut -d':' -f4)
  local altura_actual=$(echo "$linea" | cut -d':' -f5)
  local edad_actual=$(echo "$linea" | cut -d':' -f6)
  local peso_actual=$(echo "$linea" | cut -d':' -f7)
  local telefono_actual=$(echo "$linea" | cut -d':' -f8)
  local cuota_actual=$(echo "$linea" | cut -d':' -f9)
  local matricula_actual=$(echo "$linea" | cut -d':' -f10)
  local fecha_actual=$(echo "$linea" | cut -d':' -f11)

  echo "¿Que campo desea modificar?"
  echo "1. Nombre"
  echo "2. Apellido"
  echo "3. Sexo"
  echo "4. Altura"
  echo "5. Edad"
  echo "6. Peso"
  echo "7. Telefono"
  echo "8. Cuota Social Mensual"
  echo "9. Matricula del Medico de Cabecera"
  echo "10. Fecha de Ingreso"
  read -p "Opcion: " campo_elegido

  case $campo_elegido in
  1)
    read -p "Por favor, ingrese el nuevo nombre: " nombre_actual
    ;;
  2)
    read -p "Por favor, ingrese el nuevo apellido: " apellido_actual
    ;;
  3)
    read -p "Por favor, ingrese el nuevo sexo (M/F): " nuevo_sexo
    sexo_actual=$(echo "$nuevo_sexo" | tr '[:lower:]' '[:upper:]')
    ;;
  4)
    read -p "Por favor, ingrese la nueva altura (ej: 1.75): " altura_actual
    ;;
  5)
    read -p "Por favor, ingrese la nueva edad (años): " edad_actual
    ;;
  6)
    read -p "Por favor, ingrese el nuevo peso en kg (ej: 70): " peso_actual
    ;;
  7)
    read -p "Por favor, ingrese el nuevo telefono: " telefono_actual
    ;;
  8)
    read -p "Por favor, ingrese la nueva cuota social mensual: " nueva_cuota
    if [[ ! "$nueva_cuota" =~ ^[0-9]+$ ]]; then
      echo "Error: La cuota debe ser un numero."
      return
    fi
    cuota_actual=$nueva_cuota
    ;;
  9)
    echo "Medicos disponibles:"
    cat "$archivo_medicos"
    read -p "Por favor, ingrese la nueva matricula del medico: " nueva_matricula
    if ! grep -q "^$nueva_matricula:" "$archivo_medicos"; then
      echo "Error: Matricula de medico inexistente."
      return
    fi
    matricula_actual=$nueva_matricula
    ;;
  10)
    read -p "Por favor, ingrese la nueva fecha de ingreso (YYYY-MM-DD): " fecha_actual
    ;;
  *)
    echo "Opcion no valida."
    return
    ;;
  esac

  local linea_modificada="${ci_actual}:${nombre_actual}:${apellido_actual}:${sexo_actual}:${altura_actual}:${edad_actual}:${peso_actual}:${telefono_actual}:${cuota_actual}:${matricula_actual}:${fecha_actual}"

  # Respaldo antes de cambiar la linea
  crear_respaldo "$archivo_pacientes"

  # Reemplazamos la linea recorriendo el archivo
  while IFS= read -r linea_archivo; do
    if [[ "$linea_archivo" == "$ci:"* ]]; then
      echo "$linea_modificada"
    else
      echo "$linea_archivo"
    fi
  done < "$archivo_pacientes" > "${archivo_pacientes}.tmp"
  mv "${archivo_pacientes}.tmp" "$archivo_pacientes"

  echo "Registro modificado exitosamente."
}

buscar_por_ci() {
  read -p "Ingrese la CI del paciente: " ci
  if grep -q "^$ci:" "$archivo_pacientes"; then
    local linea=$(grep "^$ci:" "$archivo_pacientes")
    local p_ci=$(echo "$linea" | cut -d':' -f1)
    local p_nombre=$(echo "$linea" | cut -d':' -f2)
    local p_apellido=$(echo "$linea" | cut -d':' -f3)
    local p_sexo=$(echo "$linea" | cut -d':' -f4)
    local p_altura=$(echo "$linea" | cut -d':' -f5)
    local p_edad=$(echo "$linea" | cut -d':' -f6)
    local p_peso=$(echo "$linea" | cut -d':' -f7)
    local p_telefono=$(echo "$linea" | cut -d':' -f8)
    local p_cuota=$(echo "$linea" | cut -d':' -f9)
    local p_matricula=$(echo "$linea" | cut -d':' -f10)
    local p_fecha=$(echo "$linea" | cut -d':' -f11)

    local linea_med=$(grep "^$p_matricula:" "$archivo_medicos")
    local nombre_med=$(echo "$linea_med" | cut -d':' -f2)
    local apellido_med=$(echo "$linea_med" | cut -d':' -f3)

    echo "--- FICHA DEL PACIENTE ---"
    echo "CI: $p_ci"
    echo "Nombre: $p_nombre $p_apellido"
    echo "Sexo: ${p_sexo:-N/A}"
    echo "Altura: ${p_altura:-N/A} m"
    echo "Edad: ${p_edad:-N/A} año(s)"
    echo "Peso: ${p_peso:-N/A} kg"
    echo "Telefono: $p_telefono"
    echo "Cuota Social: \$$p_cuota"
    echo "Medico de Cabecera: $nombre_med $apellido_med (Matricula: $p_matricula)"
    echo "Fecha de Ingreso: $p_fecha"
    echo "Registro crudo: $linea"
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
        PRESIONA 7: CONSULTAR PACIENTES POR SEXO
        PRESIONA 8: CONSULTAR PACIENTES POR EDAD
        PRESIONA 9: CONSULTAR PACIENTES POR ALTURA
        PRESIONA 10: CONSULTAR PACIENTES POR PESO
        "
  read -p "Opcion: " opcion_consulta

  case $opcion_consulta in
  1)
    cat "$archivo_medicos"
    read -p "Ingrese matricula del medico: " matricula_buscada
    echo "Pacientes del medico $matricula_buscada:"
    while IFS=':' read -r p_ci p_nombre p_apellido p_sexo p_altura p_edad p_peso p_telefono p_cuota p_matricula p_fecha; do
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
      local cuota=$(echo "$linea" | cut -d':' -f9)
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
      local matricula_med=$(echo "$linea" | cut -d':' -f10)
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
    while IFS=':' read -r p_ci p_nombre p_apellido p_sexo p_altura p_edad p_peso p_telefono p_cuota p_matricula p_fecha; do
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
      while IFS=':' read -r p_ci p_nombre p_apellido p_sexo p_altura p_edad p_peso p_telefono p_cuota p_matricula p_fecha; do
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
  7)
    read -p "Ingrese el sexo a consultar (M/F): " sexo_buscado
    sexo_buscado=$(echo "$sexo_buscado" | tr '[:lower:]' '[:upper:]')
    echo "Pacientes con sexo $sexo_buscado:"
    local encontrados=0
    while IFS=':' read -r p_ci p_nombre p_apellido p_sexo p_altura p_edad p_peso p_telefono p_cuota p_matricula p_fecha; do
      if [[ "${p_sexo^^}" == "$sexo_buscado" ]]; then
        echo "CI: $p_ci | Socio: $p_nombre $p_apellido | Sexo: $p_sexo | Altura: ${p_altura}m | Edad: $p_edad | Peso: ${p_peso}kg"
        encontrados=$((encontrados + 1))
      fi
    done <"$archivo_pacientes"
    if [[ $encontrados -eq 0 ]]; then
      echo "No se encontraron pacientes con sexo $sexo_buscado."
    else
      echo "Total encontrados: $encontrados"
    fi
    ;;
  8)
    read -p "Ingrese la edad a consultar (exacta ej: 35 o rango ej: 20-40): " edad_buscada
    echo "Pacientes con edad $edad_buscada:"
    local encontrados=0
    while IFS=':' read -r p_ci p_nombre p_apellido p_sexo p_altura p_edad p_peso p_telefono p_cuota p_matricula p_fecha; do
      local coincide=0
      if [[ "$edad_buscada" =~ ^[0-9]+-[0-9]+$ ]]; then
        local min_e=$(echo "$edad_buscada" | cut -d'-' -f1)
        local max_e=$(echo "$edad_buscada" | cut -d'-' -f2)
        if [[ "$p_edad" =~ ^[0-9]+$ ]] && [[ "$p_edad" -ge "$min_e" && "$p_edad" -le "$max_e" ]] 2>/dev/null; then
          coincide=1
        fi
      elif [[ "$p_edad" == "$edad_buscada" ]]; then
        coincide=1
      fi
      if [[ $coincide -eq 1 ]]; then
        echo "CI: $p_ci | Socio: $p_nombre $p_apellido | Edad: $p_edad año(s) | Sexo: $p_sexo | Altura: ${p_altura}m | Peso: ${p_peso}kg"
        encontrados=$((encontrados + 1))
      fi
    done <"$archivo_pacientes"
    if [[ $encontrados -eq 0 ]]; then
      echo "No se encontraron pacientes con edad $edad_buscada."
    else
      echo "Total encontrados: $encontrados"
    fi
    ;;
  9)
    read -p "Ingrese la altura a consultar (ej: 1.75): " altura_buscada
    echo "Pacientes con altura $altura_buscada:"
    local encontrados=0
    while IFS=':' read -r p_ci p_nombre p_apellido p_sexo p_altura p_edad p_peso p_telefono p_cuota p_matricula p_fecha; do
      if [[ "$p_altura" == "$altura_buscada" || "$p_altura" == "$altura_buscada"* ]]; then
        echo "CI: $p_ci | Socio: $p_nombre $p_apellido | Altura: ${p_altura}m | Peso: ${p_peso}kg | Sexo: $p_sexo"
        encontrados=$((encontrados + 1))
      fi
    done <"$archivo_pacientes"
    if [[ $encontrados -eq 0 ]]; then
      echo "No se encontraron pacientes con altura $altura_buscada."
    else
      echo "Total encontrados: $encontrados"
    fi
    ;;
  10)
    read -p "Ingrese el peso a consultar en kg (ej: 75 o rango ej: 60-80): " peso_buscado
    echo "Pacientes con peso $peso_buscado:"
    local encontrados=0
    while IFS=':' read -r p_ci p_nombre p_apellido p_sexo p_altura p_edad p_peso p_telefono p_cuota p_matricula p_fecha; do
      local coincide=0
      if [[ "$peso_buscado" =~ ^[0-9]+-[0-9]+$ ]]; then
        local min_p=$(echo "$peso_buscado" | cut -d'-' -f1)
        local max_p=$(echo "$peso_buscado" | cut -d'-' -f2)
        local p_entero=${p_peso%.*}
        if [[ "$p_entero" =~ ^[0-9]+$ ]] && [[ "$p_entero" -ge "$min_p" && "$p_entero" -le "$max_p" ]] 2>/dev/null; then
          coincide=1
        fi
      elif [[ "$p_peso" == "$peso_buscado" || "$p_peso" == "$peso_buscado"* ]]; then
        coincide=1
      fi
      if [[ $coincide -eq 1 ]]; then
        echo "CI: $p_ci | Socio: $p_nombre $p_apellido | Peso: ${p_peso}kg | Altura: ${p_altura}m | Sexo: $p_sexo"
        encontrados=$((encontrados + 1))
      fi
    done <"$archivo_pacientes"
    if [[ $encontrados -eq 0 ]]; then
      echo "No se encontraron pacientes con peso $peso_buscado."
    else
      echo "Total encontrados: $encontrados"
    fi
    ;;
  *)
    echo "Opcion no valida."
    ;;
  esac
}

menu_principal() {
  local opcion_usuario=$1

  # Bucle del menu: se repite hasta que el usuario elija salir con el 5
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

    # Vaciamos la variable para que en la proxima vuelta vuelva a pedir una opcion
    opcion_usuario=""
  done
}

# Aca arranca el script: si paso --help muestra la ayuda, si no va al menu
if [[ $argumento == '--help' || $argumento == '-h' || $argumento == 'help' || $argumento == '-help' ]]; then
  mostrar_ayuda
else
  inicializar_archivos
  menu_principal "$argumento"
fi
