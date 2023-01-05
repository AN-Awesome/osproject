REM ==================================================================================
REM 
REM 이 파일은 C:/MINT64 디렉터리에 있는 Disk.img 파일이나 DiskWithPackage.img 파일을
REM 로딩하도록 되어 있습니다. 
REM
REM 실행할 디렉터리나 파일명을 바꾸고 싶다면 가장 아래에 있는 qemu-system-x86_64.exe 
REM 라인을 수정하면 됩니다.
REM 
REM ==================================================================================

REM Start qemu on windows.
@ECHO OFF

REM SDL_VIDEODRIVER=directx is faster than windib. But keyboard cannot work well.
SET SDL_VIDEODRIVER=windib

REM SDL_AUDIODRIVER=waveout or dsound can be used. Only if QEMU_AUDIO_DRV=sdl.
SET SDL_AUDIODRIVER=dsound

REM QEMU_AUDIO_DRV=dsound or fmod or sdl or none can be used. See qemu -audio-help.
SET QEMU_AUDIO_DRV=dsound

REM QEMU_AUDIO_LOG_TO_MONITOR=1 displays log messages in QEMU monitor.
SET QEMU_AUDIO_LOG_TO_MONITOR=0

REM PCI-based PC(default): -M pc 
REM ISA-based PC         : -M isapc
REM -M isapc is added for NE2000 ISA card.

REM qemu-system-x86_64.exe -L . -m 64 -fda c:/MINT64/Disk.img -boot a -localtime -M pc -serial tcp::4444,server,nowait 

REM qemu-system-x86_64.exe -L . -m 64 -fda c:/MINT64/Disk.img -hda c:/MINT64/HDD.img -boot a -localtime -M pc -serial tcp::4444,server,nowait -smp 2

REM qemu-system-x86_64.exe -L . -m 64 -fda c:/MINT64/Disk.img -hda c:/MINT64/HDD.img -boot a -localtime -M pc -serial tcp::4444,server,nowait -smp 2

REM qemu-system-x86_64.exe -L . -m 64 -fda c:/MINT64/Disk.img -boot a -localtime -M pc -serial tcp::4444,server,nowait -smp 2

REM qemu-system-x86_64.exe -L . -m 64 -fda c:/MINT64/DiskWithPackage.img -hda c:/MINT64/HDD.img -boot a -localtime -M pc -serial tcp::4444,server,nowait -smp 2

REM ==================================================================================
REM 
REM C:/MINT64 디렉터리에 있는 DiskWithPackage.img 파일을 로딩하는 옵션
REM 하드 디스크 이미지는 -hda 옵션으로 로딩 가능(위의 설정 참조)
REM
REM ==================================================================================
qemu-system-x86_64.exe -L . -m 64 -fda c:/MINT64/DiskWithPackage.img -boot a -localtime -M pc -serial tcp::4444,server,nowait -smp 2