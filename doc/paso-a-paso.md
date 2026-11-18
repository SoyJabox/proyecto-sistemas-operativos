# Desarrollo paso a paso del proyecto

Resumen de los puntos pedidos en la letra del práctico y los pasos que se siguieron para armar el programa.

---

## 1. Requisitos de la letra

- **Formato del paciente (`db/pacientes.txt`):**
  `CI:NOMBRE:APELLIDO:SEXO:ALTURA:EDAD:PESO:TELEFONO:CUOTA:MATRICULA:FECHA`
- **Formato del médico (`db/medicos.txt`):**
  `MATRICULA:NOMBRE:APELLIDO`
- **Relación:** cada paciente tiene un médico de cabecera asignado mediante su matrícula.

### Puntos a cumplir:
- La cédula (CI) no se puede repetir.
- Listar los pacientes que atiende un médico.
- Mostrar la cuota mensual de un socio.
- Mostrar el médico de cabecera de un paciente.
- Calcular el total mensual recaudado por cuotas sociales.
- Agregar una consulta extra (cantidad de pacientes por cada médico).
- Agregar consultas por datos físicos del paciente: sexo, edad, altura y peso.
- Menú principal con 5 opciones: Alta, Baja, Modificar, Consultas y Salir (la opción 5 es la única forma de cerrar el programa).
- Incluir ayuda con `--help`.
- Guardar todo en archivos `.txt` usando `:` como separador.
- Usar únicamente comandos vistos en clase (`while`, `read`, `cut`, `grep`, `mv`), sin utilizar comandos complejos no dados como `awk` o `sed`.

---

## 2. Pasos seguidos en la programación

### Paso 1: Archivos de datos y respaldos
- Se creó la carpeta `db/` para guardar `pacientes.txt` y `medicos.txt`.
- Se programó la función `inicializar_archivos()` para que, si los archivos no existen al iniciar el script, se creen automáticamente con registros de ejemplo.
- Se definió la carpeta oculta `.bak/` para guardar copias de seguridad antes de cada cambio.

### Paso 2: Función de ayuda (`--help`)
- Se armó la función `mostrar_ayuda()` que se ejecuta al pasar `--help` o `-h` como argumento, mostrando en pantalla las opciones del programa y el formato de los archivos.

### Paso 3: Guardado y copia de seguridad
- `crear_respaldo()`: copia el archivo `pacientes.txt` dentro de `.bak/` agregándole la fecha y hora actual en el nombre.
- `guardar_paciente()`: recibe los 11 datos del paciente (`CI`, `Nombre`, `Apellido`, `Sexo`, `Altura`, `Edad`, `Peso`, `Teléfono`, `Cuota`, `Matrícula`, `Fecha de ingreso`), los une con `:` y agrega la línea al final de `db/pacientes.txt`.

### Paso 4: Opciones de Alta, Baja y Modificación
- **Alta de paciente:**
  - Pide la CI (permite ingresar `0` para volver al menú), verifica que tenga entre 7 y 9 números y que no exista ya en el archivo.
  - Pide los datos en tres partes ordenadas:
    1. **Datos del usuario:** nombre, apellido, sexo (`M`/`F`), altura (metros), edad (años), peso (kg), teléfono y cuota (validando que sea numérica).
    2. **Médico:** muestra la lista de médicos disponibles y verifica que la matrícula ingresada exista en `medicos.txt`.
    3. **Fecha:** pide la fecha de ingreso (si se presiona Enter, toma la fecha del día con `date`).
  - Crea un respaldo y guarda el nuevo paciente.

- **Baja de paciente:**
  - Pide la CI, busca al paciente y muestra sus datos en pantalla.
  - Pide confirmación (`s/n`) antes de borrar. Si se confirma, hace un respaldo en `.bak/` y elimina la línea usando `grep -v` y `mv`.

- **Modificación de paciente:**
  - Pide la CI, muestra el registro actual y separa los 11 campos con `cut`.
  - Da a elegir qué campo cambiar del 1 al 10 (1. Nombre, 2. Apellido, 3. Sexo, 4. Altura, 5. Edad, 6. Peso, 7. Teléfono, 8. Cuota, 9. Médico, 10. Fecha de ingreso).
  - Valida el dato nuevo, crea un respaldo y actualiza la línea recorriendo el archivo con `while read` y `mv`.

### Paso 5: Menú de Consultas
Se programaron las 10 consultas recorriendo los archivos con `while IFS=':' read` y `cut`:
- **Opción 1:** lista el nombre y apellido de los pacientes de un médico según su matrícula.
- **Opción 2:** muestra la cuota mensual de un socio buscando por su CI.
- **Opción 3:** busca la matrícula del médico del paciente y muestra su nombre completo desde `medicos.txt`.
- **Opción 4:** suma las cuotas de todos los pacientes con `$((total + p_cuota))` y muestra el ingreso mensual total.
- **Opción 5 (Extra):** cuenta cuántos pacientes tiene asignado cada médico de la lista.
- **Opción 6:** permite ver todos los registros o buscar por CI para mostrar la ficha completa del paciente.
- **Opción 7:** filtra pacientes por sexo (`M` o `F`).
- **Opción 8:** filtra pacientes por edad exacta o rango de edades.
- **Opción 9:** filtra pacientes por altura en metros.
- **Opción 10:** filtra pacientes por peso exacto o rango en kilos.

### Paso 6: Bucle del menú principal
- Muestra el saludo al usuario con `whoami` y las 5 opciones dentro de un bucle `while true`, de modo que el programa vuelva siempre al menú hasta que se elija la opción 5.

### Paso 7: Pruebas del sistema
- Se armaron los scripts `test_e2e/run_tests.sh` y `test_e2e/test_edge_cases.sh` para comprobar que todas las opciones, consultas y validaciones funcionen sin errores.
