wsl --shutdown
$Path_vhd = (Get-ChildItem -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss | Where-Object { $_.GetValue("DistributionName") -eq 'Ubuntu-24.04' }).GetValue("BasePath") + "\ext4.vhdx"
diskpart
select vdisk file=$Path_vhd
attach vdisk readonly
compact vdisk
detach vdisk
