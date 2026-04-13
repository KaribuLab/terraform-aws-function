# Instrucciones para pruebas del módulo

Este ejemplo (`minimal`) permite validar el módulo `terraform-aws-function` con `terraform plan` sin desplegarlo en un proyecto externo.

## Requisitos previos

- **Terraform** instalado (`terraform version`).
- **Credenciales AWS** configuradas (`aws configure` o variables de entorno `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`).
- **Un bucket S3 existente** en tu cuenta (el módulo lo usa para subir el zip de la Lambda).

## Paso 1: Ver buckets existentes (evitar nombres duplicados)

Para listar los nombres de buckets y no repetir uno ya existente:

```bash
aws s3 ls
```

O solo los nombres en tabla:

```bash
aws s3api list-buckets --query "Buckets[].Name" --output table
```

## Paso 2: Crear un bucket para la prueba (si no tienes uno)

Usa un nombre único que no exista en tu cuenta/región:

```bash
aws s3 mb s3://terraform-aws-function-test --region us-east-1
```

Sustituye `terraform-aws-function-test` por el nombre que quieras (debe ser único a nivel global en S3).

## Paso 3: Configurar el bucket en el ejemplo

Crea un archivo `terraform.tfvars` dentro de `example/minimal/` con el nombre de tu bucket:

```hcl
bucket = "terraform-aws-function-test"
```

O pasa el valor por línea de comandos en los pasos siguientes con `-var="bucket=terraform-aws-function-test"`.

## Paso 4: Estructura mínima para el tipo Zip

El módulo empaqueta código desde una carpeta. Asegúrate de tener:

- **Carpeta con código**: `example/minimal/src/` con al menos un archivo (p. ej. `index.js` con un handler mínimo).
- **Carpeta para el zip**: `example/minimal/build/` (puede estar vacía; Terraform generará el zip ahí).

En `main.tf` el módulo debe recibir algo como:

- `file_location = "${path.module}/src"`
- `zip_location  = "${path.module}/build"`
- `zip_name       = "lambda.zip"`
- `bucket         = var.bucket`

Si falta alguno de estos en tu `main.tf`, añádelos al bloque `module "lambda_test"`.

## Paso 5: Inicializar y ejecutar el plan

Desde la raíz del repositorio:

```bash
cd example/minimal
terraform init
terraform plan
```

Si no usas `terraform.tfvars`, indica el bucket:

```bash
terraform plan -var="bucket=terraform-aws-function-test"
```

Si el plan termina sin errores y muestra los recursos que se crearían (Lambda, IAM, etc.), el módulo está validado correctamente.

## Resumen de comandos

| Acción              | Comando |
|---------------------|--------|
| Listar buckets      | `aws s3 ls` |
| Crear bucket        | `aws s3 mb s3://NOMBRE --region us-east-1` |
| Ir al ejemplo       | `cd example/minimal` |
| Inicializar         | `terraform init` |
| Ver el plan         | `terraform plan` o `terraform plan -var="bucket=NOMBRE"` |
