ECHO --------------------------------------------------------------------------
ECHO Automated cygwin setup
ECHO --------------------------------------------------------------------------

SETLOCAL

FOR /F %%D in ("%CD%") DO SET DRIVE=%%~dD

SET DFLTSITE=http://mirror.csclub.uwaterloo.ca/cygwin/
SET DFLTLOCALDIR=c:/Temp/cygwindownload
SET DFLTROOTDIR=%DRIVE%/cygwin
SET SITE=-s %DFLTSITE%
SET LOCALDIR=-l %DFLTLOCALDIR%
SET ROOTDIR=-R %DFLTROOTDIR%

ECHO [INFO] Downloading cygwin setup-x86_64.exe
mkdir C:\Temp\cygwindownload\
Cscript.exe getWebFile1.vbs "http://www.cygwin.com/setup-x86_64.exe" "C:\Temp\cygwindownload\setup-x86_64.exe"
if exist C:\Temp\cygwindownload\setup-x86_64.exe (
echo [INFO]: Cygwin setup was downloaded
) else (
echo [FATAL]: Cygwin setup was not downloaded
goto end
)

SET PACKAGES=-P gcc4-core,make,readline,binutils
SET PACKAGES=%PACKAGES%,diffutils,ctags
SET PACKAGES=%PACKAGES%,cygport
SET PACKAGES=%PACKAGES%,_update-info-dir,alternatives,base-cygwin,base-files,bash,bzip2,coreutils,crypt,ctags,curl,cygrunsrv,cygutils,cygwin,cygwin-doc,dash,diffutils,dos2unix,file,findutils,gawk,grep,gzip,ipc-utils,less,login,man,pbzip2,python,rebase,run,sed,subversion,tar,terminfo,tzcode,util-linux,vim,wget,which,xxd,xz,zlib,openssh,csih

REM Do the actual cygwin install
ECHO [INFO] %SystemDrive%\Temp\cygwindownload\setup-x86_64.exe -q -n -D -L %SITE% %LOCALDIR% %PACKAGES%
%SystemDrive%\Temp\cygwindownload\setup-x86_64.exe -q -n -D -L %SITE% %LOCALDIR% %PACKAGES%
ECHO [INFO] Cygwin installation is complete

echo [INFO] Installing the apt-cyg stuff as it has to be installed seperatly
%SystemDrive%\cygwin64\bin\bash.exe --norc --noprofile -c "/usr/bin/svn --force export http://apt-cyg.googlecode.com/svn/trunk/ /bin/"
%SystemDrive%\cygwin64\bin\bash.exe --norc --noprofile -c "/usr/bin/chmod +x /bin/apt-cyg"

REM stop sshd, instead of attempting to remove it
%SystemDrive%\cygwin64\bin\bash -c 'PATH=/usr/local/bin:/usr/bin:/bin:/usr/X11R6/bin cygrunsrv -E sshd'

REM Remove old sshd install
net stop OpenSSHd
REM net user sshd_server /DELETE
%SystemDrive%\cygwin64\bin\bash -c "PATH=/usr/local/bin:/usr/bin:/bin:/usr/X11R6/bin rm -R /etc/ssh*"
RMDIR /s /q "%SystemDrive%\Program Files\OpenSSH"

REM /bin/ash is the right shell for this command
cmd /c %SystemDrive%\cygwin64\bin\ash -c /bin/rebaseall

%SystemDrive%\cygwin64\bin\bash -c 'PATH=/usr/local/bin:/usr/bin:/bin:/usr/X11R6/bin /usr/bin/ssh-host-config -y -c "ntsecbinmode mintty" -w "D@rj33l1ng" --user "sshd_server"'

cmd /c if exist %Systemroot%\system32\netsh.exe netsh advfirewall firewall add rule name="SSHD" dir=in action=allow program="%SystemDrive%\cygwin64\usr\sbin\sshd.exe" enable=yes
cmd /c if exist %Systemroot%\system32\netsh.exe netsh advfirewall firewall add rule name="ssh" dir=in action=allow protocol=TCP localport=22

%SystemDrive%\cygwin64\bin\bash -c 'PATH=/usr/local/bin:/usr/bin:/bin:/usr/X11R6/bin ln -s "$(/bin/dirname $(/bin/cygpath -D))" /home/$USERNAME'

%SystemDrive%\cygwin64\bin\bash -c 'PATH=/usr/local/bin:/usr/bin:/bin:/usr/X11R6/bin ln -s "$(/bin/dirname $(/bin/cygpath -D))" /home/$USERNAME'

net start sshd

REM Put local users home directories in the Windows Profiles directory
%SystemDrive%\cygwin64\bin\bash -c 'PATH=/usr/local/bin:/usr/bin:/bin:/usr/X11R6/bin mkgroup -l'>%SystemDrive%\cygwin64\etc\group
%SystemDrive%\cygwin64\bin\bash -c 'PATH=/usr/local/bin:/usr/bin:/bin:/usr/X11R6/bin mkpasswd -l -p "$(/bin/cygpath -H)"'>%SystemDrive%\cygwin64\etc\passwd

REM Fix permissions
%SystemDrive%\cygwin64\bin\bash -c 'PATH=/usr/local/bin:/usr/bin:/bin:/usr/X11R6/bin chown vagrant "$(/bin/cygpath -H)"/vagrant'
%SystemDrive%\cygwin64\bin\bash -c 'PATH=/usr/local/bin:/usr/bin:/bin:/usr/X11R6/bin chmod 755 "$(/bin/cygpath -H)"/vagrant'
%SystemDrive%\cygwin64\bin\bash -c 'PATH=/usr/local/bin:/usr/bin:/bin:/usr/X11R6/bin chown vagrant "$(/bin/cygpath -H)"/vagrant/.ssh'
%SystemDrive%\cygwin64\bin\bash -c 'PATH=/usr/local/bin:/usr/bin:/bin:/usr/X11R6/bin chmod 755 "$(/bin/cygpath -H)"/vagrant/.ssh'
%SystemDrive%\cygwin64\bin\bash -c 'PATH=/usr/local/bin:/usr/bin:/bin:/usr/X11R6/bin chown vagrant "$(/bin/cygpath -H)"/vagrant/.ssh/authorized_keys'
%SystemDrive%\cygwin64\bin\bash -c 'PATH=/usr/local/bin:/usr/bin:/bin:/usr/X11R6/bin chmod 644 "$(/bin/cygpath -H)"/vagrant/.ssh/authorized_keys'

REM Fix corrupt recycle bin
REM http://www.winhelponline.com/blog/fix-corrupted-recycle-bin-windows-7-vista/
cmd /c rd /s /q %SystemDrive%\$Recycle.bin

:end
ENDLOCAL
EXIT /B 0
