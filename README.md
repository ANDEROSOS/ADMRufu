# ADMRufu - Version Libre (Sin Token)

![admrufu_home2](https://user-images.githubusercontent.com/67137156/170579752-e92115d1-9c53-457b-93ea-1539a5d36044.png)
![admrufu_conf](https://user-images.githubusercontent.com/67137156/170580003-3cc3b607-fe0f-4f3c-bf86-a11b71956def.png)

## Info sobre el script

Fork libre de ADMRufu - **Sin validacion de token ni licencia**

Instalacion directa sin necesidad de bot de Telegram.

---

## Instalar ADMRufu (Libre)

```bash
rm -rf install.sh* && wget https://raw.githubusercontent.com/ANDEROSOS/ADMRufu/master/install.sh && chmod 775 install.sh* && ./install.sh* --start
```

## Actualizar ADMRufu

```bash
rm -rf install.sh* && wget https://raw.githubusercontent.com/ANDEROSOS/ADMRufu/master/install.sh && chmod +x install.sh* && ./install.sh* --update
```

---

## Cambios en esta version

**Version Libre 2024**
- Eliminada validacion de licencia (install-LIC)
- No requiere token del bot de Telegram
- Instalacion directa y libre

---

## Historial de Actualizaciones

### 2024-01-16
1. Nuevo sistema de autenticacion token en linea (aToken)
2. Nuevo menu de protocolos socks python
   - Soporte python 2 y 3
   - Mas opciones para administracion y logs
3. Fix user HWID muy corto

### 2023-07-29
1. Stunnel-manager exportado a C++
   - Port de redireccion manual
   - Ver ports SSL activos desde el menu
2. Nuevo sub-menu de protocolos UDP
   - UDP request, UDP custom, UDP hysteria (udpmod)
   - Modificar puertos
   - Modificar rangos iptables

### 2023-06-03
- Fix usuarios sin internet (beta)

### 2023-05-10
- Protocolo psiphon agregado

### 2023-04-25
- Protocolo udp-custom agregado (apps HTTPCustom)

### 2023-04-07
- UDPserver: opcion de seleccion de IP, deteccion de IP NAT y publica

### 2023-03-31
- Fix user SSH/TOKEN/HWID: correcion al renovar no da datos

### 2023-01-06
1. Fix user SSH/TOKEN/HWID: visualizacion en orden alfabetico
2. Fix bugs renovar usuarios unlock

### 2022-12-24
- Nuevo script tcpbbr, nucleos mas actuales, instalacion mas segura

### 2022-12-19
1. Fix code all script SSL
2. Se inhabilito script bbr

### 2022-12-17
- Add exclucion de puertos UDP en udpServer

### 2022-11-24
1. Corregido falla al eliminar host DNS
2. Se agrego renovacion de usuario v2ray

### 2022-10-24
1. Fix code (limitador)
2. Fix code (visualizacion user SSH)
3. Admin de puertos activos movido a herramientas online
4. Nueva funcion administracion DNS

### 2022-10-10
1. Generador de sub-dominios actualizado (online, y mas seguro)
2. Fix instalador del script
3. Fix en opcion de actualizacion (muestra detalles de la actualizacion)

---

## Caracteristicas

- SSH/Dropbear
- SSL/Stunnel
- OpenVPN
- V2Ray
- WireGuard
- SlowDNS
- BadVPN/UDPGW
- Squid Proxy
- Protocolos UDP (request, custom, hysteria)
- Psiphon
- WebSocket
- Limitador de conexiones
- Monitor de usuarios
- Administracion de DNS

---

## Repositorio Original

Basado en [rudi9999/ADMRufu](https://github.com/rudi9999/ADMRufu)

---

## Creditos

Proyecto original por @Rufu99

Fork libre por ANDEROSOS
