# init.pp
#
# Startup for the ltsp module
# The ltsp module install ltsp and creates the images for each server
#
class ltsp ($package) {

    # Install the ltsp packages
    package { $package : ensure => installed }
    
    # Configure the server
    create_resources(file, hiera_hash('ltsp::files'),
        hiera_hash('ltsp::file_defaults'))

    # Create the ltsp client images
    create_resources(ltsp::image, hiera_hash('ltsp::images'),
        hiera_hash('ltsp::image_defaults'))

    Package[$package] ->
    File <| tag == 'ltsp' |> ->
    Ltsp::Client <| tag == 'ltsp' |>
}
