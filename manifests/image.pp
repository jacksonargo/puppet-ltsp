/* ltsp/manifests/client.pp
 *
 * Resource to manage ltsp client images
 * Creates a chroot image for the server.
 * Runs puppet from inside chroot to configure it.
 */

define ltsp::image (
    $image = $title,
    $image_cert,
    $image_environment = $environment,
    $image_puppetmater = $servername,
    $image_puppetmasterip = $serverip,
) {

    $chroot = "/opt/ltsp/$image"

    # First we need to tell ltsp to create our chroot
    exec { "build-$image" :
        command => "/usr/sbin/ltsp-build-client --arch amd64 --chroot $image",
        creates => $chroot,
        timeout => 0, # This will take a while so turnoff timeout
    } ->

    # Now we'll mount proc
    exec { "mount-proc-$image" :
        command => "/bin/mount -t proc proc $chroot/proc",
        unless  => "/bin/mountpoint -q $chroot/proc || /usr/bin/dpkg -l $packages",
    } ->

    # Download puppet-bootstrapper.bash
    exec { "download-bootstrapper-$image" :
        command => "/usr/bin/wget -O $chroot/root/puppet-bootstrapper.bash https://raw.githubusercontent.com/jacksonargo/puppet-bootstrapper/master/puppet-bootstrapper.bash",
        creates => "$chroot/root/puppet-bootstrapper.bash"
    } ->

    # Install puppet on the client
    exec { "install-puppet-$image" :
        command => "/usr/sbin/chroot $chroot /bin/bash /root/puppet-bootstrapper.bash",
        creates => "$chroot/usr/bin/puppet",
        environment => ["MYCERT=$image_cert", "PMCERT=$image_puppetmaster", "PMADDR=$image_puppetmasterip", "ENVIRO=$image_environment"],
        timeout => 0
    } ->

    # Run puppet in the chroot
    exec { "run-puppet-$image" : 
        command => "/usr/sbin/chroot $chroot /usr/bin/puppet apply /root/manifest.pp > /dev/null",
        timeout => 0
    }
}
