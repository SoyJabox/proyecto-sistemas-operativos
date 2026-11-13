# Diagramas de Flujo del Sistema de Mutualista

A continuación se presentan los diagramas de flujo completos del sistema en formato Mermaid, listos para visualizar o exportar a herramientas como draw.io, Mermaid Live Editor, Markdown o PDF.

---

## 1. Menú Principal y Flujo General

```mermaid
flowchart TD
    Inicio([Inicio ./app.sh]) --> ParamCheck{"¿Se pasó argumento --help?"}
    ParamCheck -- Sí --> MostrarHelp[Mostrar mensaje de ayuda en consola]
    MostrarHelp --> FinTerm([Fin del Programa])
    
    ParamCheck -- No --> CheckBD{"¿Existen db/pacientes.txt\ny db/medicos.txt?"}
    CheckBD -- No --> CrearBD[Crear directorio db y archivos base vacíos]
    CrearBD --> Menu
    CheckBD -- Sí --> Menu
    
    Menu[/Mostrar Menú Principal:
    1. Alta de Paciente
    2. Baja de Paciente
    3. Modificación de Paciente
    4. Consultas
    5. Salir/]
    
    Menu --> LeerOpcion[/Leer opción del usuario/]
    
    LeerOpcion --> Opcion{Opción elegida}
    
    Opcion -- 1 --> SubAlta[Ejecutar Módulo: Alta de Paciente]
    Opcion -- 2 --> SubBaja[Ejecutar Módulo: Baja de Paciente]
    Opcion -- 3 --> SubMod[Ejecutar Módulo: Modificación de Paciente]
    Opcion -- 4 --> SubCons[Ejecutar Módulo: Consultas]
    Opcion -- 5 --> Salir[Mostrar mensaje de despedida]
    Opcion -- Otro --> OpcInvalida[Mostrar 'Opción inválida']
    
    SubAlta --> Pausa[/Pausar: Presione Enter para continuar/]
    SubBaja --> Pausa
    SubMod --> Pausa
    SubCons --> Pausa
    OpcInvalida --> Pausa
    
    Pausa --> Menu
    Salir --> FinTerm
```

---

## 2. Proceso: Alta de Paciente

```mermaid
flowchart TD
    InicioAlta([Inicio: Alta de Paciente]) --> PedirCI[/Pedir Cédula de Identidad/]
    
    PedirCI --> ValCIFormato{"¿Formato de CI válido y no vacío?"}
    ValCIFormato -- No --> ErrCIFormato[Mostrar error: 'Formato de CI inválido']
    ErrCIFormato --> PedirCI
    
    ValCIFormato -- Sí --> ExisteCI{"¿CI ya existe en db/pacientes.txt?"}
    ExisteCI -- Sí --> ErrExiste[Mostrar error: 'El paciente ya se encuentra registrado']
    ErrExiste --> FinAlta([Fin Alta de Paciente])
    
    ExisteCI -- No --> PedirDatos[/Pedir Nombre y Apellido/]
    PedirDatos --> PedirTel[/Pedir Teléfono/]
    
    PedirTel --> PedirCuota[/Pedir Cuota Social Mensual/]
    PedirCuota --> ValCuota{"¿Cuota es numérico > 0?"}
    ValCuota -- No --> ErrCuota[Mostrar error: 'Monto de cuota inválido']
    ErrCuota --> PedirCuota
    
    ValCuota -- Sí --> MostrarMedicos[/Listar Médicos disponibles de db/medicos.txt/]
    MostrarMedicos --> PedirMatricula[/Pedir Matrícula del Médico de Cabecera/]
    
    PedirMatricula --> ExisteMed{"¿Matrícula existe en db/medicos.txt?"}
    ExisteMed -- No --> ErrMed[Mostrar error: 'Médico no existe en el sistema']
    ErrMed --> PedirMatricula
    
    ExisteMed -- Sí --> GenFecha[Obtener fecha actual YYYY-MM-DD automáticamente]
    GenFecha --> ArmarRegistro[Armar registro: CI:Nombre:Apellido:Tel:Cuota:Matricula:Fecha]
    ArmarRegistro --> GuardarRegistro[Escribir registro al final de db/pacientes.txt]
    GuardarRegistro --> MsgExito[Mostrar 'Paciente registrado con éxito']
    MsgExito --> FinAlta
```

---

## 3. Proceso: Baja de Paciente

```mermaid
flowchart TD
    InicioBaja([Inicio: Baja de Paciente]) --> PedirCIBaja[/Pedir CI del paciente a eliminar/]
    PedirCIBaja --> BuscarPaciente{"¿Existe CI en db/pacientes.txt?"}
    
    BuscarPaciente -- No --> MsgNoExiste[Mostrar 'Error: Paciente no encontrado']
    MsgNoExiste --> FinBaja([Fin Baja de Paciente])
    
    BuscarPaciente -- Sí --> MostrarFicha[/Mostrar datos del paciente encontrado/]
    MostrarFicha --> Confirmar{"¿Confirmar eliminación? S/N"}
    
    Confirmar -- No --> Cancelar[Mostrar 'Operación cancelada']
    Cancelar --> FinBaja
    
    Confirmar -- Sí --> EliminarReg[Filtrar db/pacientes.txt excluyendo dicha CI y actualizar archivo]
    EliminarReg --> MsgBajaExito[Mostrar 'Paciente eliminado correctamente']
    MsgBajaExito --> FinBaja
```

---

## 4. Proceso: Modificación de Paciente

```mermaid
flowchart TD
    InicioMod([Inicio: Modificación de Paciente]) --> PedirCIMod[/Pedir CI del paciente a modificar/]
    PedirCIMod --> BuscarMod{"¿Existe CI en db/pacientes.txt?"}
    
    BuscarMod -- No --> ErrModNoExiste[Mostrar 'Error: Paciente no registrado']
    ErrModNoExiste --> FinMod([Fin Modificación])
    
    BuscarMod -- Sí --> MostrarDatosActuales[/Mostrar datos actuales del paciente/]
    MostrarDatosActuales --> MenuCampos[/Seleccionar campo a modificar:
    1. Nombre
    2. Apellido
    3. Teléfono
    4. Cuota Social
    5. Médico de Cabecera
    6. Cancelar/]
    
    MenuCampos --> OpcCampo{Opción}
    
    OpcCampo -- 1 o 2 o 3 --> PedirNuevoTexto[/Ingresar nuevo valor/]
    OpcCampo -- 4 --> PedirNuevaCuota[/Ingresar nueva cuota/]
    PedirNuevaCuota --> ValCuotaMod{"¿Cuota válida?"}
    ValCuotaMod -- No --> PedirNuevaCuota
    ValCuotaMod -- Sí --> AplicarCambio
    
    OpcCampo -- 5 --> MostrarMedsMod[/Listar médicos/]
    MostrarMedsMod --> PedirNuevaMat[/Ingresar nueva matrícula/]
    PedirNuevaMat --> ValMedMod{"¿Existe médico?"}
    ValMedMod -- No --> PedirNuevaMat
    ValMedMod -- Sí --> AplicarCambio
    
    OpcCampo -- 6 --> CancelarMod[Mostrar 'Modificación cancelada']
    CancelarMod --> FinMod
    
    PedirNuevoTexto --> AplicarCambio[Reemplazar línea correspondiente en db/pacientes.txt]
    AplicarCambio --> MsgModOk[Mostrar 'Datos actualizados con éxito']
    MsgModOk --> FinMod
```

---

## 5. Proceso: Submenú de Consultas

```mermaid
flowchart TD
    InicioCons([Inicio: Consultas]) --> MenuConsultas[/Mostrar Menú de Consultas:
    1. Pacientes por Médico
    2. Cuota de un socio
    3. Médico de un paciente
    4. Total mensual de cuotas
    5. Cantidad total de socios
    6. Volver/]
    
    MenuConsultas --> LeerCons[/Leer opción/]
    LeerCons --> SwitchCons{Opción}
    
    %% Consulta 1
    SwitchCons -- 1 --> C1PedirMed[/Pedir Matrícula del Médico/]
    C1PedirMed --> C1BuscarMed{"¿Existe médico?"}
    C1BuscarMed -- No --> C1Error[Mostrar 'Médico no existe']
    C1BuscarMed -- Sí --> C1Filtrar[Buscar socios con esa matrícula en pacientes.txt]
    C1Filtrar --> C1Mostrar[/Mostrar Nombre y Apellido de los socios asignados/]
    C1Error --> LoopCons
    C1Mostrar --> LoopCons
    
    %% Consulta 2
    SwitchCons -- 2 --> C2PedirCI[/Pedir CI del socio/]
    C2PedirCI --> C2BuscarCI{"¿Existe socio?"}
    C2BuscarCI -- No --> C2Error[Mostrar 'Socio no encontrado']
    C2BuscarCI -- Sí --> C2Mostrar[/Extraer campo cuota y mostrar valor/]
    C2Error --> LoopCons
    C2Mostrar --> LoopCons
    
    %% Consulta 3
    SwitchCons -- 3 --> C3PedirCI[/Pedir CI del paciente/]
    C3PedirCI --> C3BuscarCI{"¿Existe socio?"}
    C3BuscarCI -- No --> C3Error[Mostrar 'Socio no encontrado']
    C3BuscarCI -- Sí --> C3ObtenerMat[Obtener Matrícula del paciente]
    C3ObtenerMat --> C3BuscarDatosMed[Buscar médico en medicos.txt]
    C3BuscarDatosMed --> C3Mostrar[/Mostrar Matrícula, Nombre y Apellido del Médico/]
    C3Error --> LoopCons
    C3Mostrar --> LoopCons
    
    %% Consulta 4
    SwitchCons -- 4 --> C4Sumar[Recorrer db/pacientes.txt sumando el campo cuota social]
    C4Sumar --> C4Mostrar[/Mostrar monto total recaudado mensualmente/]
    C4Mostrar --> LoopCons
    
    %% Consulta 5 (a elección)
    SwitchCons -- 5 --> C5Contar[Contar cantidad de líneas/registros en pacientes.txt]
    C5Contar --> C5Mostrar[/Mostrar total de socios registrados/]
    C5Mostrar --> LoopCons
    
    SwitchCons -- 6 --> FinCons([Fin Consultas / Volver al Menú Principal])
    
    LoopCons[Pausa] --> MenuConsultas
```
