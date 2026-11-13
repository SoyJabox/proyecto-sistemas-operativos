#!/bin/bash
echo ---------------- GESTION DE PACIENTES ----------------

## Variables Globales
ARG=$1
BD='./db/pacientes-min.txt'

## Funciones logicas
function_guardar_paciente(){
    local DNI=$1
    local NOM=$2
    local TEL=$3
    local CSM=$4
    local MED_MAT=$5

    # Construir la línea para el archivo (formato: DNI:nombre:telefono:costo:medico)
    local linea="${DNI}:${NOM}:${TEL}:${CSM}:${MED_MAT}"

    # Añadir al archivo (anexación) crea el archivo si no existe
    echo "$linea" >> "$BD"

    echo "Paciente ${DNI} guardado exitosamente en la base de datos."
}

function_backup(){
    local BD="$1"
    local FECHA=$(date +"%Y%m%d_%H%M%S")
    local SOLO_NOMBRE=$(basename "$BD")
    local NOMBRE_BAK="${SOLO_NOMBRE}.backup.${FECHA}"
    local BACKUP_DIR="./.bak"

    # Crear el directorio .bak si no existe
    mkdir -p "$BACKUP_DIR"

    # Crear backup en el directorio .bak
    cp "$BD" "$BACKUP_DIR/$NOMBRE_BAK"

    echo "Backup creado: $BACKUP_DIR/$NOMBRE_BAK"
}

## Funciones principales
function_alta(){
    ##Variables locales
    USER_INPUT=3
    COMPARADOR=$(cut -d: -f1  "$BD")
    echo --- Alta de paciente ---

    # Validar existencia del paciente en la BD
    read -p "Por favor, ingrese el DNI (0 para salir): " USER_INPUT

    # 1. Evalua primero la condición de salida
    if [[ "$USER_INPUT" -eq 0 ]]; then
        echo "Saliendo del script..."
        exit 0
    fi

    # 2. Valida que sean exactamente 9 dígitos numéricos (ni letras, ni espacios, ni más/menos caracteres)
    if [[ "$USER_INPUT" =~ ^[0-9]{9}$ ]]; then
        echo "Input válido: $USER_INPUT"
    else
        echo "Error: Debes ingresar exactamente 9 dígitos o solo '0' para salir."
        exit 1
    fi

    # Buscamos el DNI al principio de la línea seguido de dos puntos (:)
    if grep -q "^$USER_INPUT:" "$BD"; then
        echo "Error: El paciente con DNI $USER_INPUT ya está registrado."
        exit 0
    fi

    echo no coinciden las referencias

    # Leer datos del usuario
    read -p "Por favor, ingrese el primero nombre y primer apellido: " NOM
    read -p "Por favor, ingrese el telefono: " TEL
    read -p "Por favor, ingrese la cuota social mensual: " CSM
    read -p "Por favor, ingrese la matricula del medico de cabecera: " MED_MAT

    # Crea backup con fecha actual
    function_backup "$BD"

    # Crea un "objeto" y actualiza el archivo nuevo
    function_guardar_paciente "$USER_INPUT" "$NOM" "$TEL" "$CSM" "$MED_MAT"

    echo "Paciente añadido exitosamente."

}

function_baja(){
    echo Baja de paciente
}

function_modificar(){
    echo Modificar registro de paciente
}

function_consultar(){
    echo Consultar registros de paciente
}

main(){
    local USER_INPUT=$1

    if [[ -z "$USER_INPUT" || "$USER_INPUT" -lt 1 || "$USER_INPUT" -gt 5 ]]; then
        echo "Hola $(whoami), ¿Qué quieres hacer?"
        ### Menú
        echo "
        PRESIONA 1: ALTA DE PACIENTE
        PRESIONA 2: BAJA DE PACIENTE
        PRESIONA 3: MODIFICAR UN REGISTRO
        PRESIONA 4: CONSULTAS
        PRESIONA 5: SALIR
        "
        ### Pedimos input
        read -p "Decision: " USER_INPUT;
    fi

    ### Evaluamos input
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
            echo Salir
            ;;
        *)
            echo Por favor, siga las instrucciones
            ;;
    esac

}

### Inicio de programa
if [[ $ARG == '--help' ]]; then
    ### Comando HELP
    echo Ejecutando manual...
else
    function_alta
    # main $ARG
fi
