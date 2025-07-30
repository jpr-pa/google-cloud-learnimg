
output "vm_static_external_ip" {
  value = google_compute_address.build_static.address
}
