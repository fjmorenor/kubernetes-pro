terraform {
  backend "gcs" {
    bucket = "bucket-zafa-host-zafa" # El nombre de tu bucket de GCS 
    prefix = "bootstrap"            # Prefijo único para la identidad [cite: 195]
  }
}