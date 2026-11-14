# **Documentación del Sistema de Gestión de Pacientes** 

## **Proyecto Académico de Sistemas Operativos** 

Este documento constituye la guía oficial y exhaustiva para el uso, comprensión y mantenimiento del **Sistema de Gestión de Pacientes de Mutualista** . Ha sido diseñado con una redacción sencilla y accesible para que cualquier usuario, sin importar sus conocimientos informáticos, pueda comprender cómo funciona cada componente del programa. 

El proyecto fue desarrollado por Adrián Fros y Javier Miranda para el curso de Sistemas Operativos. 

# **1. Propósito y Objetivos del Sistema** 

El objetivo principal de esta aplicación es resolver la administración interna de socios y médicos de una entidad mutualista médica mediante una herramienta ligera que se ejecuta en la consola de comandos de Linux. 

Entre los objetivos específicos destacan: 

- **Almacenamiento liviano:** No requiere bases de datos complejas ni pesadas; todo se maneja en archivos de texto plano. 

- **Seguridad de datos:** Implementa un sistema automatizado que crea respaldos antes de cualquier modificación o borrado de información. 

- **Control estricto de registros:** Valida que la identificación de los pacientes sea única y que los médicos asignados existan en el sistema. 

- **Generación de informes:** Permite saber con exactitud la recaudación mensual y la cantidad de pacientes asignados a cada profesional de la salud. 

# **2. Estructura de Datos y Entidades** 

El sistema organiza la información a través de dos entidades principales: el **Paciente** y el **Médico** . Cada registro se almacena en una línea separada dentro de un archivo de texto, utilizando el símbolo de dos puntos (:) como delimitador entre campos. 

### **Entidad Paciente (db/pacientes.txt)** 

Representa a cada socio afiliado a la mutualista. Su estructura contiene siete datos esenciales: 

|Campo|Descripción|Ejemplo|
|---|---|---|
|**Cédula de Identidad**|Número único de 8 dígitos que<br>identifica al socio.|12345678|
|**Nombre**|Primer nombre del socio.|Juan|
|**Apellido**|Primer apellido del socio.|Pérez|
|**Teléfono**|Número de contacto<br>telefónico.|099123456|
|**Cuota Social**|Valor numérico mensual<br>pagado a la mutualista.|1500|
|**Matrícula Médico**|Código del médico de<br>cabecera asignado.|MP001|
|**Fecha de Ingreso**|Fecha de registro en formato<br>AAAA-MM-DD.|2024-03-15|



_Ejemplo de registro real dentro de la base de datos:_ 12345678:Juan:Pérez:099123456:1500:MP001:2024-03-15 

### **Entidad Médico (db/medicos.txt)** 

Guarda la información de los profesionales de la salud disponibles en la institución. 

|Campo|Descripción<br>i|Ejemplo|
|---|---|---|
|**Matrícula**|Identificador único del|MP001|
||profesional de salud.||
|**Nombre**|Nombre del médico.|Roberto|
|**Apellido**|Apellido del médico.|Álvarez|



_Ejemplo de registro real dentro de la base de datos:_ MP001:Roberto:Álvarez 

### **Relación entre Entidades** 

El sistema impone una relación de **1 a N** entre el paciente y su médico de cabecera. Cada paciente solo puede tener un médico de cabecera asignado mediante la matrícula activa de este último. Por su parte, un médico puede atender a múltiples pacientes registrados. 

# **3. Reglas de Negocio y Validaciones** 

Para garantizar que la información almacenada sea correcta y no sufra daños, el sistema aplica automáticamente las siguientes reglas: 

1. **Cédula de Identidad Única y Válida:** No se permite registrar a dos pacientes con el mismo número de cédula. La cédula debe tener exactamente 8 números enteros positivos. 

2. **Existencia del Médico:** Al inscribir o modificar a un paciente, el sistema comprueba que la matrícula médica ingresada exista previamente en el listado de médicos. 

3. **Monto de Cuota Social Válido:** La cuota pagada por el socio debe ser una cifra numérica mayor a cero. 

4. **Respaldos Automáticos (.bak):** Antes de eliminar o modificar información existente, el programa saca una copia idéntica del archivo en la carpeta oculta .bak, etiquetando la copia con la fecha y hora exactas en que se realizó la operación. 

# **4. Funcionamiento Detallado del Sistema** 

El programa funciona como una interfaz gráfica sencilla basada en menú de consola. Al ejecutar la aplicación mediante el comando bash app.sh, el sistema inicializa las carpetas necesarias y presenta las opciones disponibles. 

## **4.1 Alta de Paciente (Opción 1)** 

Permite ingresar un nuevo socio a la base de datos. El proceso realiza los siguientes pasos: 

- Solicita la Cédula de Identidad (permite presionar 0 para cancelar). 

- Verifica que el número ingresado tenga 8 dígitos y no se encuentre repetido en el archivo pacientes.txt. 

- Solicita el nombre completo, número telefónico y el monto de la cuota mensual. 

- Muestra en pantalla el listado de médicos disponibles y pide ingresar la matrícula asignada. 

- Solicita la fecha de ingreso (si se presiona Enter sin escribir nada, el sistema asigna la fecha actual automáticamente). 

- Ejecuta una copia de respaldo preventiva en la carpeta .bak y guarda la información guardada al final del archivo. 

## **4.2 Baja de Paciente (Opción 2)** 

Permite retirar a un socio del padrón activo: 

- Solicita la cédula del paciente a eliminar. 

- Busca el registro; si no existe, notifica el error en pantalla. 

- Muestra la ficha completa del paciente para confirmar que es el usuario correcto. 

- Genera un archivo de respaldo específico con el prefijo deleted_ guardado en la carpeta oculta .bak. 

- Elimina la línea correspondiente al socio sin alterar los datos de los demás pacientes. 

## **4.3 Modificación de Registro (Opción 3)** 

Permite actualizar los datos individuales de un socio sin necesidad de reescribir todo el formulario: 

- Pide la cédula del socio a modificar. 

- Presenta los datos actuales y despliega un submenú para elegir qué campo cambiar: 

   - a. Nombre y Apellido 

   - b. Teléfono 

   - c. Cuota Social Mensual 

   - d. Matrícula del Médico de Cabecera 

   - e. Fecha de Ingreso 

- Realiza las validaciones correspondientes sobre el nuevo valor ingresado (por ejemplo, validando que el nuevo médico exista). 

- Realiza una copia de seguridad en .bak y reemplaza la línea por los datos actualizados. 

## **4.4 Submenú de Consultas (Opción 4)** 

Este módulo proporciona reportes interactivos para analizar la información almacenada: 

- **Consulta 1 (Pacientes por Médico):** Pide la matrícula de un médico y devuelve el nombre y apellido de todos los socios bajo su cuidado. 

- **Consulta 2 (Cuota de un Socio):** Pide la cédula de un paciente y muestra su nombre junto con el monto exacto de su cuotas social mensual. 

- **Consulta 3 (Médico de un Paciente):** Muestra el nombre completo y la matrícula del médico asignado a una cédula específica. 

- **Consulta 4 (Total Mensual de Recaudación):** Suma automáticamente las cuotas de todos los socios registrados e informa el total de ingresos mensuales de la mutualista. 

- **Consulta 5 (Pacientes Asignados por Médico):** Recorre el listado de médicos y cuenta de forma detallada cuántos pacientes atendidos tiene cada profesional. 

- **Consulta 6 (Búsqueda General / Ver Todos):** Muestra el listado completo de registros guardados o permite realizar una búsqueda individual por documento. 

# **5. Estructura de Archivos del Proyecto** 

El sistema se organiza en la siguiente estructura de carpetas y archivos en el sistema operativo: 

proyecto-mutualista/ 

├── app.sh                 # Código ejecutable principal del programa en Bash 

- ├── db/                    # Carpeta contenedora de la base de datos activa 

- │├── pacientes.txt      # Archivo delimitado por ':' con registros de pacientes 

- │└── medicos.txt        # Archivo delimitado por ':' con el catálogo de médicos 

- └── .bak/                  # Carpeta oculta de seguridad donde se guardan backups 

# **6. Manual de Ayuda Integrado (--help)** 

El sistema incluye una función de ayuda ejecutable directamente desde la consola sin necesidad de entrar al menú interactivo. 

Para consultar esta documentación rápida, se debe ejecutar: 

bash app.sh --help 

Al hacerlo, el programa despliega en pantalla la descripción del software, el formato de almacenamiento de los archivos, la lista de argumentos aceptados y ejemplos de uso para el operador. 

