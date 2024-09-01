function Create-OS {
    param (
        [string]$kernelSourceDir = "\\wsl.localhost\Ubuntu\home\spectex\os",   # Directory containing your kernel source files
        [string]$outputDir = "\\wsl.localhost\Ubuntu\home\spectex\os",
        [string]$vmd = "C:\Program Files\Oracle\VirtualBox",                 # Directory where the .bin and .iso files will be saved
        [string]$isoFileName = "mykernel.iso",                         # Name of the ISO file to create
        [string]$vmName = "MeinKampf"                                 # Name of the VirtualBox VM to create
    )

    # Step 1: Compile the kernel to create mykernel.bin
    Write-Output "Compiling the kernel..."
    Set-Location -Path $kernelSourceDir
    wsl make all               # Assuming you have a Makefile in your kernel source directory
    if (!(Test-Path "$kernelSourceDir\mykernel.bin")) {
        Write-Error "Kernel compilation failed. mykernel.bin not found."
        return
    }
    wsl cp mykernel.iso $outputDir

    # Step 2: Generate the ISO image from mykernel.bin
    # Write-Output "Creating the ISO image..."
    # Set-Location -Path $outputDir
    # wsl make mykernel.iso
    # wsl genisoimage -o $isoFileName mykernel.bin

    if (!(Test-Path "$outputDir\$isoFileName")) {
        Write-Error "ISO creation failed. $isoFileName not found."
        return
    }
    Set-Location -Path $vmd 
    # Step 3: Create a new VirtualBox VM and configure it
    Write-Output "Setting up the VirtualBox VM..."
    .\VBoxManage createvm --name $vmName --ostype Other --register
    .\VBoxManage modifyvm $vmName --memory 1024 --boot1 dvd --nic1 nat
    .\VBoxManage storagectl $vmName --name "IDE Controller" --add ide --controller PIIX4
    .\VBoxManage storageattach $vmName --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "$outputDir\$isoFileName"

    # Step 4: Start the VM
    Write-Output "Starting the VirtualBox VM..."
    .\VBoxManage startvm $vmName
}

# Example usage
Create-OS
