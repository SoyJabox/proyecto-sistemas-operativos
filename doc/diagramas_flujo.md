# Diagramas de Flujo del Programa

Diagramas en formato Mermaid que muestran paso a paso cómo funciona cada opción del script `app.sh`.

---

## 1. Menú Principal y Arranque

```mermaid
flowchart TD
    Inicio([Inicio ./app.sh]) --> ParamCheck{"¿Se pasó --help o -h?"}
    ParamCheck -- Sí --> MostrarHelp[Mostrar texto de ayuda]
    MostrarHelp --> FinTerm([Fin del programa])
    
    ParamCheck -- No --> CheckBD{"¿Existen pacientes.txt y medicos.txt?"}
    CheckBD -- No --> CrearBD[Crear carpeta db y archivos con datos de ejemplo]
    CrearBD --> Menu
    CheckBD -- Sí --> Menu
    
    Menu[/Mostrar Menú Principal:
    1. Alta de Paciente
    2. Baja de Paciente
    3. Modificar un registro
    4. Consultas
    5. Salir/]
    
    Menu --> LeerOpcion[/Leer opción del usuario/]
    LeerOpcion --> Opcion{Opción elegida}
    
    Opcion -- 1 --> SubAlta[Ir a Alta de Paciente]
    Opcion -- 2 --> SubBaja[Ir a Baja de Paciente]
    Opcion -- 3 --> SubMod[Ir a Modificar Paciente]
    Opcion -- 4 --> SubCons[Ir a Consultas]
    Opcion -- 5 --> Salir[Mostrar mensaje de salida]
    Opcion -- Otro --> OpcInvalida[Mostrar aviso de opción inválida]
    
    SubAlta --> Menu
    SubBaja --> Menu
    SubMod --> Menu
    SubCons --> Menu
    OpcInvalida --> Menu
    Salir --> FinTerm
```

---

## 2. Alta de Paciente

Los datos se piden en tres partes ordenadas: primero los datos del usuario (personales y físicos), luego el médico de cabecera y por último la fecha de ingreso.

```mermaid
flowchart TD
    InicioAlta([Inicio: Alta de Paciente]) --> PedirCI[/Pedir Cédula de Identidad/]
    
    PedirCI --> ValCI0{"¿Ingresó 0?"}
    ValCI0 -- Sí --> FinAlta([Volver al menú principal])
    ValCI0 -- No --> ValCIFormato{"¿Tiene entre 7 y 9 números?"}
    
    ValCIFormato -- No --> ErrCIFormato[Mostrar error de formato de CI]
    ErrCIFormato --> FinAlta
    
    ValCIFormato -- Sí --> ExisteCI{"¿La CI ya está en pacientes.txt?"}
    ExisteCI -- Sí --> ErrExiste[Avisar que el paciente ya está registrado]
    ErrExiste --> FinAlta
    
    ExisteCI -- No --> PedirDatos[/Pedir Nombre y Apellido/]
    PedirDatos --> PedirClinicas[/Pedir datos físicos del paciente:
    - Sexo M/F
    - Altura en metros
    - Edad en años
    - Peso en kg/]
    
    PedirClinicas --> PedirTel[/Pedir Teléfono/]
    PedirTel --> PedirCuota[/Pedir Cuota mensual/]
    PedirCuota --> ValCuota{"¿La cuota es un número?"}
    ValCuota -- No --> ErrCuota[Avisar que la cuota debe ser numérica]
    ErrCuota --> FinAlta
    
    ValCuota -- Sí --> MostrarMedicos[/Mostrar lista de médicos de medicos.txt/]
    MostrarMedicos --> PedirMatricula[/Pedir matrícula del médico de cabecera/]
    
    PedirMatricula --> ExisteMed{"¿Existe la matrícula en medicos.txt?"}
    ExisteMed -- No --> ErrMed[Avisar que la matrícula no existe]
    ErrMed --> FinAlta
    
    ExisteMed -- Sí --> PedirFecha[/Pedir fecha de ingreso Enter para fecha actual/]
    PedirFecha --> RespaldoAlta[Crear copia de respaldo en .bak/]
    RespaldoAlta --> ArmarRegistro[Armar línea con los 11 datos:
    CI:Nombre:Apellido:Sexo:Altura:Edad:Peso:Tel:Cuota:Matricula:Fecha]
    ArmarRegistro --> GuardarRegistro[Agregar línea al final de pacientes.txt]
    GuardarRegistro --> MsgExito[Mostrar: Paciente añadido exitosamente]
    MsgExito --> FinAlta
```

---

## 3. Baja de Paciente

```mermaid
flowchart TD
    InicioBaja([Inicio: Baja de Paciente]) --> PedirCIBaja[/Pedir CI del paciente a eliminar/]
    PedirCIBaja --> BuscarPaciente{"¿Existe la CI en pacientes.txt?"}
    
    BuscarPaciente -- No --> MsgNoExiste[Avisar que no se encontró al paciente]
    MsgNoExiste --> FinBaja([Volver al menú])
    
    BuscarPaciente -- Sí --> MostrarFicha[/Mostrar datos del paciente encontrado/]
    MostrarFicha --> Confirmar{"¿Confirmar eliminación? s/n"}
    
    Confirmar -- No --> Cancelar[Mostrar: Operación cancelada]
    Cancelar --> FinBaja
    
    Confirmar -- Sí --> RespaldoBaja[Crear copia de respaldo en .bak/]
    RespaldoBaja --> EliminarReg[Filtrar con grep -v hacia temporal y mover con mv]
    EliminarReg --> MsgBajaExito[Mostrar: Paciente eliminado exitosamente]
    MsgBajaExito --> FinBaja
```

---

## 4. Modificar un Registro

```mermaid
flowchart TD
    InicioMod([Inicio: Modificar Paciente]) --> PedirCIMod[/Pedir CI del paciente/]
    PedirCIMod --> BuscarMod{"¿Existe la CI en pacientes.txt?"}
    
    BuscarMod -- No --> ErrModNoExiste[Avisar que no se encontró al paciente]
    ErrModNoExiste --> FinMod([Volver al menú])
    
    BuscarMod -- Sí --> MostrarDatosActuales[/Mostrar registro actual y separar los 11 datos/]
    MostrarDatosActuales --> MenuCampos[/Elegir dato a cambiar:
    1. Nombre   2. Apellido  3. Sexo
    4. Altura   5. Edad      6. Peso
    7. Teléfono 8. Cuota     9. Médico
    10. Fecha/]
    
    MenuCampos --> OpcCampo{Opción elegida}
    
    OpcCampo -- 1 o 2 o 7 o 10 --> PedirNuevoTexto[/Pedir nuevo texto o fecha/]
    OpcCampo -- 3 o 4 o 5 o 6 --> PedirNuevaClinica[/Pedir nuevo dato físico/]
    OpcCampo -- 8 --> PedirNuevaCuota[/Pedir nueva cuota y validar que sea número/]
    OpcCampo -- 9 --> MostrarMedsMod[/Mostrar médicos y validar matrícula/]
    OpcCampo -- Otro --> ErrOpcMod[Avisar que la opción no es válida]
    ErrOpcMod --> FinMod
    
    PedirNuevoTexto --> AplicarCambio[Hacer respaldo en .bak/, actualizar con while read y mv]
    PedirNuevaCuota --> AplicarCambio
    PedirNuevaClinica --> AplicarCambio
    MostrarMedsMod --> AplicarCambio
    
    AplicarCambio --> MsgModOk[Mostrar: Registro modificado exitosamente]
    MsgModOk --> FinMod
```

---

## 5. Submenú de Consultas (10 Opciones)

```mermaid
flowchart TD
    InicioCons([Inicio: Consultas]) --> MenuConsultas[/Mostrar las 10 opciones de consulta:
    1. Pacientes de un médico
    2. Cuota de un socio
    3. Médico de un paciente
    4. Total mensual de ingresos
    5. Cantidad de pacientes por médico
    6. Mostrar todos o buscar por CI
    7. Consultar por sexo
    8. Consultar por edad
    9. Consultar por altura
    10. Consultar por peso/]
    
    MenuConsultas --> LeerCons[/Leer opción/]
    LeerCons --> SwitchCons{Opción}
    
    %% Consulta 1
    SwitchCons -- 1 --> C1PedirMed[/Pedir matrícula del médico/]
    C1PedirMed --> C1Filtrar[Recorrer pacientes.txt y comparar matrícula]
    C1Filtrar --> C1Mostrar[/Mostrar nombre y apellido de sus pacientes/]
    C1Mostrar --> FinCons([Volver al menú principal])
    
    %% Consulta 2
    SwitchCons -- 2 --> C2PedirCI[/Pedir CI del socio/]
    C2PedirCI --> C2BuscarCI{"¿Existe la CI?"}
    C2BuscarCI -- Sí --> C2Mostrar[/Mostrar nombre y valor de su cuota/]
    C2BuscarCI -- No --> C2Err[Avisar que no se encontró al socio]
    C2Mostrar --> FinCons
    C2Err --> FinCons
    
    %% Consulta 3
    SwitchCons -- 3 --> C3PedirCI[/Pedir CI del paciente/]
    C3PedirCI --> C3BuscarCI{"¿Existe la CI?"}
    C3BuscarCI -- Sí --> C3Mostrar[/Buscar médico en medicos.txt y mostrar su nombre/]
    C3BuscarCI -- No --> C3Err[Avisar que no se encontró al paciente]
    C3Mostrar --> FinCons
    C3Err --> FinCons
    
    %% Consulta 4
    SwitchCons -- 4 --> C4Sumar[Sumar las cuotas de todos los pacientes]
    C4Sumar --> C4Mostrar[/Mostrar el ingreso mensual total/]
    C4Mostrar --> FinCons
    
    %% Consulta 5
    SwitchCons -- 5 --> C5Contar[Contar cuántos pacientes tiene cada médico]
    C5Contar --> C5Mostrar[/Mostrar lista de médicos con su cantidad/]
    C5Mostrar --> FinCons
    
    %% Consulta 6
    SwitchCons -- 6 --> C6Sub[/1: Mostrar todos  2: Buscar por CI/]
    C6Sub -- 1 --> C6Todos[/Mostrar todo el archivo/]
    C6Sub -- 2 --> C6Ficha[/Mostrar ficha completa del paciente/]
    C6Todos --> FinCons
    C6Ficha --> FinCons
    
    %% Consulta 7
    SwitchCons -- 7 --> C7Pedir[/Pedir sexo M o F/]
    C7Pedir --> C7Filtrar[Filtrar pacientes con ese sexo]
    C7Filtrar --> C7Mostrar[/Mostrar pacientes y total encontrados/]
    C7Mostrar --> FinCons
    
    %% Consulta 8
    SwitchCons -- 8 --> C8Pedir[/Pedir edad exacta ej: 35 o rango ej: 20-40/]
    C8Pedir --> C8Filtrar[Filtrar pacientes por edad]
    C8Filtrar --> C8Mostrar[/Mostrar pacientes que coinciden/]
    C8Mostrar --> FinCons
    
    %% Consulta 9
    SwitchCons -- 9 --> C9Pedir[/Pedir altura en metros ej: 1.75/]
    C9Pedir --> C9Filtrar[Filtrar pacientes por altura]
    C9Filtrar --> C9Mostrar[/Mostrar pacientes que coinciden/]
    C9Mostrar --> FinCons
    
    %% Consulta 10
    SwitchCons -- 10 --> C10Pedir[/Pedir peso en kg ej: 75 o rango ej: 60-80/]
    C10Pedir --> C10Filtrar[Filtrar pacientes por peso]
    C10Filtrar --> C10Mostrar[/Mostrar pacientes que coinciden/]
    C10Mostrar --> FinCons
    
    SwitchCons -- Otro --> ErrCons[Mostrar: Opción no válida]
    ErrCons --> FinCons
```
