# Informe del Proyecto - Gestión de Pacientes

**Materia:** Sistemas Operativos (2do Año - B.T. Informática)  
**Docente:** Prof. Sandro Amaral  
**Integrantes:** Adrián Fros y Javier Miranda  

---

## 1. Introducción

Este proyecto consiste en un programa en Bash para administrar los socios y médicos de una mutualista médica desde la terminal de Linux.

El objetivo fue resolver todas las funciones pedidas utilizando archivos de texto simples (`.txt`) y los comandos vistos en clase (`while`, `read`, `cut`, `grep`, `mv` y sumas básicas en Bash), sin depender de bases de datos externas ni de comandos que no dimos en el curso como `awk` o `sed`.

---

## 2. Cómo se guardan los datos

Toda la información se guarda dentro de la carpeta `db/` en dos archivos de texto, donde cada dato va separado por dos puntos (`:`):

### Archivo de Pacientes (`db/pacientes.txt`)
Cada línea representa a un paciente y guarda 11 datos en este orden:

```text
CI:NOMBRE:APELLIDO:SEXO:ALTURA:EDAD:PESO:TELEFONO:CUOTA:MATRICULA:FECHA
```

| Dato | Qué guarda | Ejemplo |
|---|---|---|
| **CI** | Cédula de identidad (de 7 a 9 números, sin repetir) | `12345678` |
| **Nombre** | Nombre del paciente | `Juan` |
| **Apellido** | Apellido del paciente | `Perez` |
| **Sexo** | Sexo del paciente (`M` o `F`) | `M` |
| **Altura** | Estatura en metros | `1.75` |
| **Edad** | Edad en años | `35` |
| **Peso** | Peso en kilogramos | `78` |
| **Teléfono** | Teléfono de contacto | `099123456` |
| **Cuota** | Valor de la cuota mensual en números | `1500` |
| **Matrícula** | Código del médico asignado | `MP001` |
| **Fecha** | Fecha de ingreso (`AAAA-MM-DD`) | `2020-03-15` |

*Ejemplo de línea en el archivo:*
```text
12345678:Juan:Perez:M:1.75:35:78:099123456:1500:MP001:2020-03-15
```

### Archivo de Médicos (`db/medicos.txt`)
Contiene la lista de médicos disponibles en la mutualista:

```text
MATRICULA:NOMBRE:APELLIDO
```

*Ejemplo de línea en el archivo:*
```text
MP001:Roberto:Alvarez
```

Cada paciente tiene asignado un médico mediante su matrícula, y un mismo médico puede atender a varios pacientes.

---

## 3. Controles y validaciones del programa

Para evitar que se carguen datos incorrectos en los archivos, el script revisa lo siguiente:

1. **Cédula válida y sin repetir:** comprueba que la cédula tenga entre 7 y 9 dígitos numéricos y busca con `grep` que no esté ya anotada en `db/pacientes.txt`. También permite escribir `0` para cancelar y volver al menú.
2. **Cuota numérica:** verifica que el monto de la cuota contenga solo números.
3. **Médico existente:** antes de asignar o cambiar un médico, revisa que la matrícula ingresada exista en `db/medicos.txt`.
4. **Copia de seguridad automática (`.bak/`):** antes de agregar, borrar o modificar un paciente, el programa copia el archivo original a la carpeta oculta `.bak/` agregándole la fecha y hora.
5. **Salida únicamente con la opción 5:** el menú principal se repite dentro de un bucle `while true` y solo finaliza cuando el usuario elige la opción 5.

---

## 4. Funcionamiento de cada opción del menú

El programa se inicia ejecutando `bash app.sh`. Si los archivos de la carpeta `db/` no existen, el script los crea automáticamente con datos de ejemplo.

### 4.1 Alta de Paciente (Opción 1)
Para que la carga de datos siga un orden lógico, el programa pide la información en tres etapas:
1. **Datos del usuario:** solicita la cédula, **nombre**, **apellido**, **sexo** (`M`/`F`), **altura** (metros), **edad** (años), **peso** (kg), **teléfono** y **cuota mensual** (si se presiona `Enter` en los datos físicos, guarda `N/A` por defecto).
2. **Médico de cabecera:** muestra la lista de médicos de `db/medicos.txt` y pide ingresar la **matrícula** correspondiente.
3. **Fecha de ingreso:** pide la **fecha de ingreso** (si se presiona `Enter`, coloca automáticamente la fecha del día).

Por último, crea una copia de respaldo en `.bak/` y guarda la nueva línea al final de `db/pacientes.txt`.

### 4.2 Baja de Paciente (Opción 2)
- Pide la cédula del paciente que se quiere eliminar.
- Si lo encuentra, muestra sus datos en pantalla y pide confirmación (`s/n`).
- Si el usuario confirma con `s`, crea un respaldo en `.bak/` y borra la línea del archivo filtrando con `grep -v` hacia un archivo temporal y renombrándolo con `mv`.

### 4.3 Modificar un Registro (Opción 3)
- Pide la cédula del paciente y muestra sus datos actuales.
- Muestra un menú del 1 al 10 para elegir qué dato cambiar:
  1. Nombre
  2. Apellido
  3. Sexo
  4. Altura
  5. Edad
  6. Peso
  7. Teléfono
  8. Cuota Social Mensual
  9. Matrícula del Médico de Cabecera
  10. Fecha de Ingreso
- Pide el nuevo valor, realiza las validaciones necesarias, hace el respaldo en `.bak/` y reemplaza la línea recorriendo el archivo con `while read` y guardándolo con `mv`.

### 4.4 Consultas (Opción 4)
Cuenta con un submenú de 10 consultas resueltas leyendo los archivos con `while IFS=':' read` y `cut`:
- **1. Pacientes de un médico:** pide la matrícula y muestra el nombre y apellido de los socios que atiende ese médico.
- **2. Cuota de un socio:** busca al socio por CI y muestra su nombre y el valor de su cuota mensual.
- **3. Médico de un paciente:** busca al paciente por CI y muestra cómo se llama su médico de cabecera.
- **4. Total mensual de ingresos:** recorre todos los pacientes sumando el valor de sus cuotas e informa el total mensual recaudado.
- **5. Cantidad de pacientes por médico (Consulta extra):** recorre la lista de médicos y cuenta cuántos pacientes tiene asignado cada uno.
- **6. Mostrar todos los registros / Buscar por CI:** permite listar todo el archivo o buscar a un paciente por cédula para ver su ficha completa con todos los datos personales y clínicos.
- **7. Consultar pacientes por sexo:** filtra y muestra los pacientes según su sexo (`M` o `F`) e indica cuántos se encontraron.
- **8. Consultar pacientes por edad:** permite buscar por una edad exacta (ej: `35`) o por un rango de edades (ej: `20-40`).
- **9. Consultar pacientes por altura:** busca pacientes que coincidan con la altura indicada en metros (ej: `1.75`).
- **10. Consultar pacientes por peso:** busca pacientes por un peso exacto en kilos (ej: `75`) o dentro de un rango (ej: `60-80`).

---

## 5. Organización de carpetas y archivos

```text
Proyecto-SO/
├── app.sh                 # Script principal del programa
├── README.md              # Informe general del proyecto
├── db/                    # Carpeta de datos
│   ├── pacientes.txt      # Lista de pacientes (11 campos separados por ':')
│   └── medicos.txt        # Lista de médicos
├── .bak/                  # Copias de seguridad automáticas
├── doc/                   # Documentación y diagramas
│   ├── informe_proyecto.html
│   ├── Informe de Proyecto - Gestión de Pacientes.pdf
│   ├── diagramas_flujo.md
│   ├── paso-a-paso.md
│   └── diagrama_claude/   # Diagramas de flujo en formato SVG
└── test_e2e/              # Scripts de prueba
    ├── run_tests.sh       # Pruebas generales del sistema (30 pruebas)
    └── test_edge_cases.sh # Pruebas de validaciones y errores (6 pruebas)
```

---

## 6. Uso desde la terminal y ayuda (`--help`)

Para abrir el menú principal:
```bash
bash app.sh
```

Para ver la guía rápida de ayuda sin entrar al menú:
```bash
bash app.sh --help
```

También se puede pasar el número de opción como parámetro para entrar directo:
```bash
bash app.sh 1    # Entra directo al Alta de paciente
bash app.sh 4    # Entra directo al menú de Consultas
```

---

## 7. Pruebas del programa

En la carpeta `test_e2e/` se incluyen dos scripts para probar que todas las funciones y validaciones respondan bien:

```bash
# Ejecutar las 30 pruebas de funcionamiento general:
bash test_e2e/run_tests.sh

# Ejecutar las 6 pruebas de casos de error:
bash test_e2e/test_edge_cases.sh
```

---

## 8. Uso de herramientas de IA

De acuerdo con lo conversado en clase, se deja constancia de que se utilizaron herramientas de Inteligencia Artificial como apoyo para:
- Armar los scripts de pruebas automáticas (`test_e2e/`).
- Dar formato visual en HTML/CSS al informe para exportarlo a PDF en tamaño A4.
- Pasar los diagramas de flujo a imágenes SVG.
