# Proyecto Sistemas Operativos

## Información necesaria de actores (formato pedido):
  - **Usuario**: CI:NOMBRE:APELLIDO:TELEFONO:CUOTA_SOCIAL_MENSUAL:MATRICULA_MEDICO_CABECERA:FECHA_INGRESO
  - **MEDICO**: MATRICULA:NOMBRE:APELLIDO;
  - **Relacionamiento**: MATRICULA_MEDICO_CABECERA (MATRICULA en medico)

## Reglas:
  - *CI NO REPETIBLE*
  - Filtrar pacientes por medico
  - Cuota de socio determinado
  - 1:1 paciente - medico
  - Total mensual de ingreso de la mutualista por concepto de una cuota social
  - Consultas manuales
  - Estética a elección
  - Debe contar con menu para:
    - Alta
    - Baja
    - Modificación
    - Consulta
    - Salir *imperativa*

  - **Programar --help**
  - Base de datos tipo TXT.

## Pasos a seguir:

  1. **Preparar los archivos y carpetas base:**
     - Crear la carpeta `db` con el archivo `pacientes.txt` donde se van a guardar todos los datos separados por dos puntos (`:`).
     - Definir una carpeta oculta (`.bak`) para ir guardando copias de seguridad automáticas cada vez que se modifique o borre algo.

  2. **Armar la estructura inicial y la ayuda (`--help`):**
     - Configurar el arranque del programa para que reconozca si el usuario escribe un comando directo al ejecutarlo (como un número de opción o `--help`).
     - Mostrar un manual rápido en pantalla si se pide ayuda, explicando qué hace cada opción antes de entrar al programa.

  3. **Crear las funciones de guardado y respaldo:**
     - Hacer una función dedicada a sacar una copia del archivo de pacientes con fecha y hora antes de hacer cualquier cambio importante.
     - Hacer otra función que reciba los datos de un paciente nuevo, acomode el nombre y apellido con dos puntos para mantener el formato y los agregue al final del archivo.

  4. **Desarrollar las opciones principales (CRUD):**
     - **Alta:** Pedir la cédula/DNI (permitiendo salir con `0`), verificar que tenga 9 números y revisar que no esté ya registrada. Si es nueva, pedir el resto de los datos, hacer un respaldo y guardarla.
     - **Baja:** Buscar al paciente por su documento, mostrar sus datos actuales para confirmar, guardar una copia de respaldo del archivo y borrar esa línea.
     - **Modificación:** Buscar al paciente y preguntar qué dato puntual se quiere cambiar (nombre y apellido, teléfono, cuota o médico). Guardar respaldo y actualizar solo ese campo.
     - **Consulta:** Dar dos opciones: mostrar la lista completa de pacientes o buscar a uno en específico escribiendo su documento.

  5. **Diseñar el menú principal y conectar todo:**
     - Crear la pantalla de bienvenida saludando al usuario y mostrando las 5 opciones disponibles (Alta, Baja, Modificar, Consultas y Salir).
     - Conectar cada número con su función correspondiente para que el programa responda según lo que elija el usuario, o permitir que entre directo si ya pasó el número al abrir el script.

  6. **Completar los requisitos que faltan del proyecto:**
     - Agregar el campo de `FECHA_INGRESO` al registrar o editar un paciente.
     - Crear el archivo `medicos.txt` y validar que la matrícula del médico exista al asignarlo a un paciente.
     - Sumar en el menú de consultas la opción de filtrar pacientes por médico y calcular cuánto recauda la mutualista por mes con las cuotas sociales[cite: 1, 2].
