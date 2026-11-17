# **Documentación del Sistema de Gestión de Pacientes**

## **Proyecto Académico de Sistemas Operativos**

Este documento constituye la guía oficial para el uso, comprensión y mantenimiento del **Sistema de Gestión de Pacientes de Mutualista**. Ha sido diseñado con una redacción clara y accesible para que cualquier usuario o evaluador pueda comprender cómo funciona cada componente del programa.

El proyecto fue desarrollado por Adrián Fros y Javier Miranda para el curso de 2do Año de Sistemas Operativos (B.T. Informática, Prof. Sandro Amaral).

---

# **1. Propósito y Objetivos del Sistema**

El objetivo principal de esta aplicación es resolver la administración interna de socios y médicos de una entidad mutualista médica mediante una herramienta ligera que se ejecuta en la consola de comandos de Linux.

Entre los objetivos específicos destacan:

- **Almacenamiento liviano:** No requiere bases de datos complejas ni dependencias externas; todo se maneja en archivos de texto plano.
- **Herramientas nativas de Bash:** Resuelto utilizando comandos y estructuras nativas (`while`, `read`, `cut`, `grep`, `sed` y aritmética de Bash).
- **Seguridad e integridad de datos:** Implementa un sistema automatizado que crea respaldos con marca temporal (`.bak`) antes de cualquier alta, modificación o borrado de información.
- **Control estricto de registros:** Valida que la identificación de los pacientes sea única (no duplicados), formatos válidos y que los médicos asignados existan en el sistema.
- **Generación de informes:** Permite consultar la recaudación mensual total, listar pacientes por médico, conocer el médico de cabecera de un afiliado y contabilizar pacientes asignados a cada profesional.

---

# **2. Estructura de Datos y Entidades**

El sistema organiza la información a través de dos entidades principales: el **Paciente** y el **Médico**. Cada registro se almacena en una línea separada dentro de un archivo de texto plano, utilizando el símbolo de dos puntos (`:`) como delimitador entre campos.

### **Entidad Paciente (`db/pacientes.txt`)**

Representa a cada socio afiliado a la mutualista. Su estructura contiene siete datos esenciales:

| Campo | Descripción | Formato / Validación | Ejemplo |
|---|---|---|---|
| **Cédula de Identidad** | Documento identificador único del socio. | Numérico (7 a 9 dígitos, no repetible) | 12345678 |
| **Nombre** | Primer nombre (o nombres) del socio. | Texto | Juan |
| **Apellido** | Apellido (o apellidos) del socio. | Texto | Pérez |
| **Teléfono** | Número de contacto telefónico. | Numérico / Texto | 099123456 |
| **Cuota Social** | Valor mensual pagado a la mutualista. | Entero positivo | 1500 |
| **Matrícula Médico** | Código del médico de cabecera asignado. | Debe existir en `db/medicos.txt` | MP001 |
| **Fecha de Ingreso** | Fecha de registro en la institución. | Formato AAAA-MM-DD (por defecto hoy) | 2024-03-15 |

*Ejemplo de registro real dentro de la base de datos:*
```text
12345678:Juan:Pérez:099123456:1500:MP001:2024-03-15
```

### **Entidad Médico (`db/medicos.txt`)**

Guarda la información de los profesionales de la salud disponibles en la institución.

| Campo | Descripción | Ejemplo |
|---|---|---|
| **Matrícula** | Identificador único del profesional de salud. | MP001 |
| **Nombre** | Nombre del médico. | Roberto |
| **Apellido** | Apellido del médico. | Álvarez |

*Ejemplo de registro real dentro de la base de datos:*
```text
MP001:Roberto:Álvarez
```

### **Relación entre Entidades**

El sistema impone una relación de **1 a N** entre el paciente y su médico de cabecera:
- Cada paciente tiene un único médico de cabecera asignado mediante la matrícula activa de este último.
- Por su parte, un médico puede atender a múltiples pacientes registrados.

---

# **3. Reglas de Negocio y Validaciones**

Para garantizar que la información almacenada sea correcta y consistente, el sistema aplica automáticamente las siguientes reglas:

1. **Cédula de Identidad Única y Válida:** No se permite registrar a dos pacientes con el mismo número de cédula. La cédula debe tener entre 7 y 9 dígitos numéricos (permite ingresar `0` para cancelar la operación).
2. **Existencia del Médico:** Al inscribir o modificar el médico de un paciente, el sistema comprueba que la matrícula exista en el catálogo de médicos (`db/medicos.txt`).
3. **Monto de Cuota Social Válido:** La cuota debe ser un valor numérico entero positivo.
4. **Respaldos Automáticos (`.bak/`):** Antes de agregar, modificar o eliminar registros, el programa genera una copia de seguridad fecheada en la carpeta oculta `.bak/` siguiendo el patrón:
   ```text
   pacientes.txt.backup.YYYYMMDD_HHMMSS
   ```
5. **Salida Imperativa:** El programa se mantiene en ejecución en un bucle interactivo continuo, siendo la opción `5 (Salir)` la única forma autorizada de finalizar el script.

---

# **4. Funcionamiento Detallado del Sistema**

El programa cuenta con un menú interactivo en consola y admite también parámetros directos por línea de comandos. Se ejecuta mediante:

```bash
bash app.sh
```

Al arrancar, inicializa automáticamente los directorios y archivos con datos de prueba si aún no existen.

## **4.1 Alta de Paciente (Opción 1)**

Permite ingresar un nuevo socio al padrón:
- Solicita la Cédula de Identidad (valida entre 7 y 9 dígitos y permite ingresar `0` para cancelar y volver al menú).
- Comprueba que la CI no se encuentre ya registrada en `db/pacientes.txt`.
- Solicita nombre y apellido en pasos separados (permitiendo nombres compuestos sin alterar delimitadores).
- Solicita el teléfono y la cuota social (validando que sea un número).
- Muestra los médicos disponibles y solicita la matrícula, validando su existencia.
- Solicita la fecha de ingreso (al presionar `Enter` toma automáticamente la fecha actual `AAAA-MM-DD`).
- Genera un respaldo preventivo en `.bak/` y añade la línea al final de `db/pacientes.txt`.

## **4.2 Baja de Paciente (Opción 2)**

Permite retirar a un socio del padrón activo:
- Solicita la cédula del paciente a dar de baja.
- Busca el registro; si no existe, informa el error en pantalla.
- Muestra el registro completo del paciente encontrado y solicita confirmación expresa (`s/n`).
- Si se confirma, crea un respaldo preventivo en `.bak/` y elimina la línea correspondiente mediante `sed -i`.

## **4.3 Modificación de Registro (Opción 3)**

Permite actualizar un dato individual de un socio manteniendo intactos los restantes:
- Solicita la cédula del socio a modificar y muestra sus datos actuales.
- Despliega el menú de selección de campo:
  1. Nombre
  2. Apellido
  3. Teléfono
  4. Cuota Social Mensual (valida formato numérico)
  5. Matrícula del Médico de Cabecera (muestra catálogo y valida existencia)
  6. Fecha de Ingreso
- Genera un respaldo preventivo en `.bak/` y reemplaza la línea en el archivo utilizando `sed -i`.

## **4.4 Submenú de Consultas (Opción 4)**

Proporciona reportes interactivos procesados con lecturas nativas (`while IFS=':' read` y `cut`):
- **Consulta 1 (Pacientes de un médico):** Solicita la matrícula y lista el nombre y apellido de todos los socios bajo su cuidado.
- **Consulta 2 (Cuota de un socio):** Busca por CI e informa el nombre del socio y el monto exacto de su cuota social.
- **Consulta 3 (Médico de un paciente):** Busca por CI y muestra el nombre del paciente junto con el nombre completo y matrícula de su médico de cabecera.
- **Consulta 4 (Total mensual de recaudación):** Suma aritméticamente las cuotas de todos los socios activos e informa el ingreso mensual total de la mutualista.
- **Consulta 5 (Pacientes por médico - Consulta Extra):** Recorre el catálogo de médicos y cuenta la cantidad exacta de pacientes asignados a cada doctor.
- **Consulta 6 (Mostrar todos los registros / Buscar por CI):** Permite ver el padrón completo o buscar la ficha exacta de un socio por documento.

---

# **5. Estructura de Archivos del Proyecto**

```text
proyecto-sistemas-operativos/
├── app.sh                 # Script ejecutable principal en Bash
├── README.md              # Documentación principal del repositorio
├── db/                    # Carpeta de almacenamiento de datos
│   ├── pacientes.txt      # Archivo delimitado por ':' con registros de pacientes
│   └── medicos.txt        # Archivo delimitado por ':' con catálogo de médicos
├── .bak/                  # Carpeta de respaldos automáticos temporales
├── doc/                   # Documentación académica y especificaciones
│   ├── informe_proyecto.html
│   ├── Informe de Proyecto - Gestión de Pacientes.pdf
│   ├── Documentacion_del_Proyecto.md.docx
│   ├── paso-a-paso.md
│   ├── Proyecto+Segundo+SO++2026+-+Pacientes.md
│   └── diagrama_claude/   # Diagramas de flujo en formato SVG
└── test_e2e/              # Suite de pruebas automatizadas
    ├── run_tests.sh       # Pruebas End-to-End completas
    └── test_edge_cases.sh # Pruebas de casos de borde y validaciones
```

---

# **6. Manual de Ayuda Integrado (`--help`)**

El sistema incluye una función de ayuda ejecutable directamente desde la terminal al estilo Unix/Linux:

```bash
bash app.sh --help
# o también:
bash app.sh -h
```

También es posible ingresar directamente a una opción del menú indicándola como argumento:

```bash
bash app.sh 1    # Ingresa directo al Alta de paciente
bash app.sh 4    # Ingresa directo a Consultas
```

---

# **7. Pruebas Automatizadas (Testing E2E)**

El proyecto incluye dos suites de pruebas automatizadas en Bash para verificar la integridad de las funciones sin intervención manual:

```bash
# Ejecutar suite principal E2E (18 pruebas)
bash test_e2e/run_tests.sh

# Ejecutar suite de casos de borde (6 pruebas)
bash test_e2e/test_edge_cases.sh
```

---

# **8. Transparencia en el Uso de Herramientas de IA**

En cumplimiento de las buenas prácticas académicas, se deja constancia del uso de herramientas de Inteligencia Artificial exclusivamente como asistencia en:
- **Testing:** diseño y armado de las pruebas de extremo a extremo (`test_e2e/run_tests.sh` y `test_edge_cases.sh`).
- **Formateo y maquetado de informes:** maquetado en HTML/CSS del informe para su exportación a PDF A4.
- **Diagramación:** vectorización y ajuste visual de los diagramas de flujo de los procesos.
