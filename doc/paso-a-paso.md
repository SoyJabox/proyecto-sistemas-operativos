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
  - 
## Pasos a seguir:

  1. Generar BD, utilizando IA.
  2. Diseñar concepto de programa
  3. Generar UI interactuable:
    - Menu principal con botonera
