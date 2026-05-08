# --- CONFIGURACIÓN DEL ESTADO REMOTO ---
# Este bloque asegura que el archivo .tfstate se guarde de forma segura en la nube.

terraform {
  # Backend: Google Cloud Storage para evitar pérdida de datos y permitir trabajo en equipo
  backend "gcs" {
    bucket = "bucket-zafa-host-zafa" # Nombre del bucket de GCS previamente creado
    prefix = "dev"                 # Organiza el estado dentro de la carpeta 'dev/'
  }
}