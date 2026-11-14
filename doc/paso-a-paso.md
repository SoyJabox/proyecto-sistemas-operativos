# Proyecto Sistemas Operativos

## Información necesaria de actores (formato pedido):
  - **Usuario**: CI:NOMBRE:APELLIDO:TELEFONO:CUOTA_SOCIAL_MENSUAL:MATRICULA_MEDICO_CABECERA:FECHA_INGRESO
  - **MEDICO**: MATRICULA:NOMBRE:APELLIDO
  - **Relacionamiento**: MATRICULA_MEDICO_CABECERA (MATRICULA en medico)

## Reglas:
  - *CI NO REPETIBLE*
  - Filtrar pacientes por medico
  - Cuota de socio determinado
  - Médico de un paciente
  - 1:1 paciente - medico
  - Total mensual de ingreso de la mutualista por concepto de cuota social
  - Consulta extra a elección (cantidad de socios por médico)
  - Estética a elección
  - Debe contar con menu para:
    - Alta
    - Baja
    - Modificación
    - Consulta
    - Salir *imperativa* (única forma de cerrar el programa)

  - **Programar --help** (ayuda no interactiva estilo Linux)
  - Base de datos tipo TXT con delimitador `:`
  - Sin usar comandos no dados en clase (como `awk`), resolviendo todo con herramientas nativas de Bash (`while`, `read`, `cut`, `grep`, `sed` y operaciones aritméticas).

---

## Pasos del desarrollo:

  1. **Preparar los archivos y carpetas base:**
     - Crear la carpeta `db/` con los archivos de texto `pacientes.txt` y `medicos.txt` separados por dos puntos (`:`).
     - Si los archivos no existen al arrancar, inicializarlos con datos de prueba válidos.
     - Definir una carpeta oculta (`.bak/`) para ir guardando copias de seguridad automáticas con fecha y hora cada vez que se modifique o borre un registro.

  2. **Armar la estructura inicial y la ayuda (`--help`):**
     - Configurar el arranque del programa para que reconozca si el usuario pasa un argumento directo desde la terminal (un número de opción o `--help` / `-h`).
     - Si pide ayuda, mostrar el manual de uso con la explicación de cada opción, la estructura de los archivos y salir enseguida.

  3. **Funciones de guardado y respaldo:**
     - Implementar `crear_respaldo()` para copiar el archivo de pacientes a `.bak/` antes de cualquier alta, baja o edición.
     - Implementar `guardar_paciente()` recibiendo los 7 campos por separado (CI, nombre, apellido, teléfono, cuota, matrícula del médico y fecha de ingreso) y agregando la línea limpia con `:` al final del archivo.

  4. **Desarrollar las operaciones principales (CRUD):**
     - **Alta de paciente:**
       - Pedir la CI (permitiendo volver al menú escribiendo `0`).
       - Validar que sea un número de entre 7 y 9 dígitos y comprobar que no esté repetida en `pacientes.txt`.
       - Pedir nombre y apellido en campos separados para no romper el formato si hay nombres compuestos.
       - Pedir teléfono y validar que la cuota sea un valor numérico.
       - Mostrar la lista de médicos disponibles desde `medicos.txt` y verificar que la matrícula ingresada realmente exista.
       - Pedir la fecha de ingreso (o presionar Enter para que tome automáticamente la fecha de hoy).
       - Sacar respaldo y guardar el registro.
     - **Baja de paciente:**
       - Pedir la CI del paciente a borrar.
       - Si existe, mostrar el registro encontrado en pantalla.
       - Pedir confirmación al usuario (`¿Esta seguro? s/n`) para evitar borrados por error.
       - Sacar respaldo en `.bak/` y borrar la línea con `sed -i`.
     - **Modificación de paciente:**
       - Pedir la CI y mostrar los datos actuales del paciente.
       - Preguntar qué campo puntual se quiere cambiar (1. Nombre, 2. Apellido, 3. Teléfono, 4. Cuota, 5. Médico de cabecera, 6. Fecha de ingreso).
       - Validar el nuevo dato (número en cuota, existencia en médicos).
       - Sacar respaldo y actualizar la línea en el archivo usando `sed -i`.

  5. **Módulo de Consultas:**
     - Menú interactivo con las consultas solicitadas en la letra:
       - **Opción 1:** Mostrar nombre y apellido de todos los socios de un médico ingresando su matrícula (recorriendo con `while IFS=':' read`).
       - **Opción 2:** Cuota mensual de un socio determinado buscando por su CI.
       - **Opción 3:** Médico de cabecera de un paciente (relaciona la matrícula del paciente con `medicos.txt` y muestra el nombre completo del doctor).
       - **Opción 4:** Total mensual de ingresos de la mutualista (suma acumulativa de todas las cuotas con `$((total + cuota))`).
       - **Opción 5 (Consulta extra):** Cantidad de socios asignados por cada médico registrado.
       - **Opción 6:** Ver todos los registros del archivo o buscar uno puntual por CI.

  6. **Menú principal y control de flujo:**
     - Saludo al usuario con `whoami` y despliegue del menú con las 5 opciones obligatorias.
     - Bucle `while true` que solo finaliza cuando el usuario elige la opción 5.
     - Limpieza de variables entre vueltas para que el menú siempre vuelva a mostrarse de forma prolija.

  7. **Pruebas y Verificación:**
     - Creación de pruebas de extremo a extremo (E2E) en `test_e2e/run_tests.sh` y de casos borde en `test_e2e/test_edge_cases.sh` para verificar automáticamente todas las opciones, validaciones y respaldos.
