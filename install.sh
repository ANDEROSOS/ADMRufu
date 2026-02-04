#!/bin/bash

# ADMRufu Libre - Sin validacion de licencia
# Fork por ANDEROSOS

module="$(pwd)/module"
rm -rf ${module}
wget -O ${module} "https://raw.githubusercontent.com/rudi9999/Herramientas/main/module/module" &>/dev/null
[[ ! -e ${module} ]] && echo "Error descargando modulo" && exit
chmod +x ${module} &>/dev/null
source ${module}

CTRL_C(){
  rm -rf ${module}; exit
}

if [[ ! $(id -u) = 0 ]]; then
  clear
  msg -bar
  print_center -ama "ERROR DE EJECUCION"
  msg -bar
  print_center -ama "DEVE EJECUTAR DESDE EL USUSRIO ROOT"
  msg -bar
  CTRL_C
fi

trap "CTRL_C" INT TERM EXIT

ADMRufu="/etc/ADMRufu" && [[ ! -d ${ADMRufu} ]] && mkdir ${ADMRufu}
ADM_inst="${ADMRufu}/install" && [[ ! -d ${ADM_inst} ]] && mkdir ${ADM_inst}
tmp="${ADMRufu}/tmp" && [[ ! -d ${tmp} ]] && mkdir ${tmp}
SCPinstal="$HOME/install"

cp -f $0 ${ADMRufu}/install.sh 2>/dev/null
rm $(pwd)/$0 &> /dev/null

stop_install(){
  title "INSTALACION CANCELADA"
  exit
}

time_reboot(){
  print_center -ama "REINICIANDO VPS EN $1 SEGUNDOS"
  REBOOT_TIMEOUT="$1"

  while [ $REBOOT_TIMEOUT -gt 0 ]; do
     print_center -ne "-$REBOOT_TIMEOUT-\r"
     sleep 1
     : $((REBOOT_TIMEOUT--))
  done
  reboot
}

repo_install(){
  link="https://raw.githubusercontent.com/ANDEROSOS/ADMRufu/master/Repositorios/$VERSION_ID.list"
  case $VERSION_ID in
    8*|9*|10*|11*|16.04*|18.04*|20.04*|20.10*|21.04*|21.10*|22.04*)
      [[ ! -e /etc/apt/sources.list.back ]] && cp /etc/apt/sources.list /etc/apt/sources.list.back
      wget -O /etc/apt/sources.list ${link} &>/dev/null
      ;;
    12*)
      [[ ! -e /etc/apt/sources.list.back ]] && cp /etc/apt/sources.list /etc/apt/sources.list.back
      wget -O /etc/apt/sources.list ${link} &>/dev/null
      echo "Debian 12 detectado - repositorios actualizados"
      ;;
    24.04*)
      echo "Ubuntu 24.04 detectado"
      ;;
  esac
}

dependencias(){
  # Lista de paquetes esenciales para Debian 12
  soft="sudo curl wget zip unzip bsdmainutils ufw python3 python3-pip openssl screen cron iptables lsof nano at plocate gawk grep bc jq socat netcat-openbsd net-tools cowsay figlet sqlite3 libsqlite3-dev locales"

  echo ""
  echo "Instalando paquetes uno por uno..."
  echo ""

  for pkg in $soft; do
    printf "  %-25s" "$pkg"

    # Instalar mostrando errores si falla
    output=$(DEBIAN_FRONTEND=noninteractive apt-get install -y $pkg 2>&1)

    if [[ $? -eq 0 ]]; then
      echo -e "\e[32mOK\e[0m"
    else
      echo -e "\e[31mFAIL\e[0m"
      # Mostrar el error
      echo "$output" | grep -i "error\|unable\|cannot\|failed" | head -3
    fi
  done

  echo ""

  # Instalar nodejs y npm por separado (pueden no estar disponibles)
  echo "Instalando nodejs/npm..."
  apt-get install -y nodejs npm 2>/dev/null || echo "nodejs/npm no disponible, continuando..."

  # Instalar lolcat via gem o pip si no está disponible
  if ! command -v lolcat &>/dev/null; then
    apt-get install -y ruby 2>/dev/null && gem install lolcat 2>/dev/null || echo "lolcat no instalado"
  fi

  # Crear enlace python si no existe
  [[ ! -e /usr/bin/python ]] && [[ -e /usr/bin/python3 ]] && ln -sf /usr/bin/python3 /usr/bin/python

  echo ""
  echo "Dependencias procesadas."
}

verificar_arq(){
  unset ARQ
  case $1 in
    menu|menu_inst.sh|tool_extras.sh|chekup.sh|bashrc)ARQ="${ADMRufu}";;
    ADMRufu)ARQ="/usr/bin";;
    message.txt)ARQ="${tmp}";;
    *)ARQ="${ADM_inst}";;
  esac
  mv -f ${SCPinstal}/$1 ${ARQ}/$1
  chmod +x ${ARQ}/$1
}

error_fun(){
  msg -bar3
  print_center -verm "Falla al descargar $1"
  msg -bar3
  [[ -d ${SCPinstal} ]] && rm -rf ${SCPinstal}
  exit
}

install_completa(){
  title "INSTALADOR ADMRufu LIBRE"
  print_center -ama "Instalacion completa sin reinicio intermedio"
  msg -bar3
  read -rp "$(msg -verm2 " Desea continuar? [S/N]:") " -e -i S opcion
  [[ "$opcion" != @(s|S) ]] && stop_install

  title "INSTALADOR ADMRufu"
  print_center -ama 'Modificar zona horaria?'
  msg -bar
  read -rp "$(msg -ama " Modificar la zona horaria? [S/N]:") " -e -i N opcion
  [[ "$opcion" != @(n|N) ]] && source <(curl -sSL "https://raw.githubusercontent.com/ANDEROSOS/ADMRufu/master/online/timeZone.sh")

  title "INSTALADOR ADMRufu"
  print_center -ama "Diagnosticando sistema..."
  msg -bar3

  # Verificar si es root
  echo "Usuario: $(whoami)"
  echo "UID: $(id -u)"

  if [[ $(id -u) -ne 0 ]]; then
    echo "ERROR: No eres root. Ejecuta: sudo su"
    exit 1
  fi

  # Verificar espacio en disco
  echo "Espacio en disco:"
  df -h /

  # Matar procesos de apt que puedan estar bloqueando
  echo "Liberando bloqueos de apt..."
  killall apt apt-get dpkg 2>/dev/null
  rm -f /var/lib/dpkg/lock-frontend 2>/dev/null
  rm -f /var/lib/dpkg/lock 2>/dev/null
  rm -f /var/cache/apt/archives/lock 2>/dev/null
  rm -f /var/lib/apt/lists/lock 2>/dev/null

  # Configurar dpkg
  echo "Configurando dpkg..."
  dpkg --configure -a

  # Limpiar cache de apt
  echo "Limpiando cache apt..."
  rm -rf /var/lib/apt/lists/*
  mkdir -p /var/lib/apt/lists/partial

  # Configurar repositorios para Debian 12
  echo "Configurando repositorios para Debian 12..."
  cat > /etc/apt/sources.list << 'EOFAPT'
deb http://deb.debian.org/debian/ bookworm main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
deb http://deb.debian.org/debian/ bookworm-updates main contrib non-free non-free-firmware
EOFAPT

  echo "Contenido de sources.list:"
  cat /etc/apt/sources.list

  msg -bar3
  title "INSTALADOR ADMRufu"
  print_center -ama "Actualizando lista de paquetes..."
  echo ""

  # Actualizar apt con TODO el output visible
  apt-get update 2>&1

  if [[ $? -ne 0 ]]; then
    echo ""
    echo "===== ERROR en apt update ====="
    echo "Intentando reparar..."
    apt-get update --fix-missing 2>&1
  fi

  echo ""
  echo "Probando instalacion de curl..."
  apt-get install -y curl 2>&1

  if [[ $? -ne 0 ]]; then
    echo ""
    echo "===== ERROR: No se puede instalar curl ====="
    echo "Verificando conectividad..."
    ping -c 2 deb.debian.org
    echo ""
    echo "Presiona Enter para continuar de todos modos o Ctrl+C para salir"
    read
  fi

  title "INSTALADOR ADMRufu"
  print_center -ama "$PRETTY_NAME"
  print_center -verd "INSTALANDO DEPENDENCIAS"
  msg -bar3
  dependencias
  msg -bar3
  print_center -azu "Removiendo paquetes obsoletos"
  apt-get autoremove -y &>/dev/null
  sleep 2
}

source /etc/os-release; export PRETTY_NAME

# Limpiar cualquier entrada anterior en bashrc que pueda causar loops
sed -i '/ADMRufu/d' /root/.bashrc 2>/dev/null
sed -i '/ADMRufu/d' /etc/bash.bashrc 2>/dev/null

case $1 in
  -s|--start|-u|--update)
    install_completa
    ;;
  -t|--test)
    echo "Modo test"
    exit
    ;;
  *)
    echo "Uso: $0 --start | --update"
    echo "  --start   Instalacion nueva"
    echo "  --update  Actualizar instalacion"
    exit
    ;;
esac

title "INSTALADOR ADMRufu"
fun_ip

msg -ne " Verificando Datos: "
cd $HOME

arch='ADMRufu
bashrc
budp.sh
cert.sh
chekup.sh
chekuser.sh
confDNS.sh
domain.sh
filebrowser.sh
limitador.sh
menu
menu_inst.sh
openvpn.sh
PDirect.py
PGet.py
POpen.py
PPriv.py
PPub.py
sockspy.sh
squid.sh
swapfile.sh
tcpbbr.sh
tool_extras.sh
userHWID
userSSH
userTOKEN
userV2ray.sh
userWG.sh
v2ray.sh
wireguard.sh
ws-cdn.sh
WS-Proxy.js'

lisArq="https://raw.githubusercontent.com/ANDEROSOS/ADMRufu/master/old"

ver=$(curl -sSL "https://raw.githubusercontent.com/ANDEROSOS/ADMRufu/master/vercion")
echo "$ver" > ${ADMRufu}/vercion
echo -e "Idioma=es_ES.utf8\nRutaLocales=locale" > ${ADMRufu}/lang.ini

title -ama '[ADMRufu Libre - ANDEROSOS]'
print_center -ama 'INSTALANDO SCRIPT ADMRufu'
sleep 2; del 1

[[ ! -d ${SCPinstal} ]] && mkdir ${SCPinstal}
print_center -ama 'Descarga de archivos.....'

for arqx in $(echo $arch); do
  wget -O ${SCPinstal}/${arqx} ${lisArq}/${arqx} > /dev/null 2>&1 && {
    verificar_arq "${arqx}"
  } || {
    del 1
    print_center -verm2 "Instalacion fallida de $arqx"
    sleep 2s
    error_fun "${arqx}"
  }
done

url='https://github.com/ANDEROSOS/ADMRufu/raw/master/Utils'

autoStart="${ADMRufu}/bin" && [[ ! -d $autoStart ]] && mkdir $autoStart
varEntorno="${ADMRufu}/sbin" && [[ ! -d $varEntorno ]] && mkdir $varEntorno

cat <<EOF>$varEntorno/ls-cmd
#!/bin/bash
echo 'menu'
ls /etc/ADMRufu/sbin|sed 's/ /\n/'
EOF
chmod +x $varEntorno/ls-cmd

wget --no-cache -O $autoStart/autoStart "$url/autoStart/autoStart" &>/dev/null; chmod +x $autoStart/autoStart
wget --no-cache -O $autoStart/auto-update "$url/auto-update/auto-update" &>/dev/null; chmod +x $autoStart/auto-update

wget --no-cache -O ${ADMRufu}/install/udp-custom "$url/udp-custom/udp-custom" &>/dev/null; chmod +x ${ADMRufu}/install/udp-custom
wget --no-cache -O ${ADMRufu}/install/psiphon-manager "$url/psiphon/psiphon-manager" &>/dev/null; chmod +x ${ADMRufu}/install/psiphon-manager
wget --no-cache -O ${varEntorno}/dropBear "$url/dropBear/dropBear" &>/dev/null; chmod +x ${varEntorno}/dropBear

wget --no-cache -O ${varEntorno}/protocolsUDP "$url/protocolsUDP/protocolsUDP" &>/dev/null;           chmod +x ${varEntorno}/protocolsUDP
wget --no-cache -O ${varEntorno}/udprequest   "$url/protocolsUDP/udprequest/udprequest" &>/dev/null;  chmod +x ${varEntorno}/udprequest
wget --no-cache -O ${varEntorno}/udpcustom    "$url/protocolsUDP/udpcustom/udpcustom" &>/dev/null;    chmod +x ${varEntorno}/udpcustom
wget --no-cache -O ${varEntorno}/udp-udpmod   "$url/protocolsUDP/udpmod/udp-udpmod" &>/dev/null;      chmod +x ${varEntorno}/udp-udpmod
wget --no-cache -O ${varEntorno}/Stunnel      "$url/Stunnel/Stunnel" &>/dev/null;                     chmod +x ${varEntorno}/Stunnel
wget --no-cache -O ${varEntorno}/Slowdns      "$url/SlowDNS/Slowdns" &>/dev/null;                     chmod +x ${varEntorno}/Slowdns
wget --no-cache -O ${varEntorno}/cmd          "$url/mine_port/cmd" &>/dev/null;                       chmod +x ${varEntorno}/cmd
wget --no-cache -O ${varEntorno}/epro-ws      "$url/epro-ws/epro-ws" &>/dev/null;                     chmod +x ${varEntorno}/epro-ws
wget --no-cache -O ${varEntorno}/socksPY      "$url/socksPY/socksPY" &>/dev/null;                     chmod +x ${varEntorno}/socksPY

wget --no-cache -O ${varEntorno}/monitor      "$url/user-manager/monitor/monitor" &>/dev/null;        chmod +x ${varEntorno}/monitor
wget --no-cache -O ${varEntorno}/online       "$url/user-manager/monitor/online/online" &>/dev/null;  chmod +x ${varEntorno}/online
wget --no-cache -O ${varEntorno}/user-info    "$url/user-managers/user-info" &>/dev/null;             chmod +x ${varEntorno}/user-info
wget --no-cache -O ${varEntorno}/aToken-mng   "$url/aToken/aToken-mng" &>/dev/null;                   chmod +x ${varEntorno}/aToken-mng
wget --no-cache -O ${varEntorno}/makeUser     "$url/user-managers/makeUser" &>/dev/null;              chmod +x ${varEntorno}/makeUser
wget --no-cache -O ${varEntorno}/genssl       "$url/genCert/genssl" &>/dev/null;                      chmod +x ${varEntorno}/genssl
wget --no-cache -O ${autoStart}/sql           "$url/Csqlite/sql" &>/dev/null;                         chmod +x ${autoStart}/sql
wget --no-cache -O ${varEntorno}/banner       "$url/banner/banner" &>/dev/null;                       chmod +x ${varEntorno}/banner
wget --no-cache -O ${varEntorno}/monitor-m    "$url/user-manager/monitor/monitor-m/monitor-m" &>/dev/null; chmod +x ${varEntorno}/monitor-m

wget --no-cache -O ${varEntorno}/userSSH      "$url/user-managers/userSSH/userSSH" &>/dev/null;       chmod +x ${varEntorno}/userSSH
wget --no-cache -O ${varEntorno}/userHWID     "$url/user-managers/userHWID/userHWID" &>/dev/null;     chmod +x ${varEntorno}/userHWID
wget --no-cache -O ${varEntorno}/userTOKEN    "$url/user-managers/userTOKEN/userTOKEN" &>/dev/null;   chmod +x ${varEntorno}/userTOKEN

wget --no-cache -O ${autoStart}/limit    "$url/user-managers/limitador/limit" &>/dev/null;   chmod +x ${autoStart}/limit
${autoStart}/limit 2>/dev/null

wget --no-cache -O /etc/ADMRufu/uninstall "https://github.com/ANDEROSOS/ADMRufu/raw/master/uninstall" &>/dev/null; chmod +x /etc/ADMRufu/uninstall

if [[ -e $autoStart/autoStart ]]; then
  $autoStart/autoStart -e /etc/ADMRufu/autoStart 2>/dev/null
fi

rm -rf /etc/profile.d/rufu.sh

sbinList=$(ls ${varEntorno})
for i in $sbinList; do
  ln -sf ${varEntorno}/$i /usr/bin/$i 2>/dev/null
done

del 1

print_center -verd 'Instalacion completa'
sleep 2s
rm -f $HOME/lista-arq
[[ -d ${SCPinstal} ]] && rm -rf ${SCPinstal}
rm -rf /usr/bin/menu
rm -rf /usr/bin/adm
ln -sf /usr/bin/ADMRufu /usr/bin/menu
ln -sf /usr/bin/ADMRufu /usr/bin/adm
ln -sf /etc/ADMRufu/reseller /etc/ADMRufu/tmp/message.txt 2>/dev/null

# Limpiar bashrc de entradas anteriores
sed -i '/ADMRufu/d' /etc/bash.bashrc 2>/dev/null
sed -i '/ADMRufu/d' /root/.bashrc 2>/dev/null

# Agregar solo el source del bashrc de ADMRufu
echo '[[ -e /etc/ADMRufu/bashrc ]] && source /etc/ADMRufu/bashrc' >> /etc/bash.bashrc

locale-gen en_US.UTF-8 &>/dev/null
update-locale LANG=en_US.UTF-8 LANGUAGE=en LC_ALL=en_US.UTF-8 &>/dev/null
echo -e "LANG=en_US.UTF-8\nLANGUAGE=en\nLC_ALL=en_US.UTF-8" > /etc/default/locale
[[ ! $(cat /etc/shells|grep "/bin/false") ]] && echo -e "/bin/false" >> /etc/shells

clear
title "-- ADMRufu INSTALADO --"
print_center -verd "Instalacion completada exitosamente"
print_center -ama "Escriba 'menu' para acceder al panel"
msg -bar

mv -f ${module} /etc/ADMRufu/module 2>/dev/null

print_center -ama "El VPS se reiniciara en 10 segundos"
print_center -ama "Despues del reinicio escriba: menu"
time_reboot "10"
