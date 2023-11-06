# README.md

<!-- TOC -->
* [README.md](#readmemd)
  * [Utilisation 🔧](#utilisation-)
  * [Fonctionnement du script 💻](#fonctionnement-du-script-)
    * [Conditions](#conditions)
    * [Dépendances](#dépendances)
<!-- TOC -->

## Utilisation 🔧

- Rendre le script executable :

```bash
fabien@debian:~$ chmod +x chroot.sh
```

- Lancer le script en root (nécessaire pour installer les dépendances via `apt`

```bash
fabien@debian:~/calms-sdv/exercice_1$ sudo ./chroot.sh
Installing dependencies...
Hit:1 http://deb.debian.org/debian bookworm InRelease
Hit:2 http://deb.debian.org/debian bookworm-updates InRelease
Hit:3 http://deb.debian.org/debian-security bookworm-security InRelease
Reading package lists... Done
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
libncurses6 is already the newest version (6.4-4).
0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
OK
Creating chroot hierarchy...
OK
You may now use the chroot environment as follows:
chroot exo1/ msnake or chroot exo1/ bash
```

- Lancer un bash ou `msnake` directement dans le jail :

```bash
fabien@debian:~/calms-sdv/exercice_1$ sudo chroot exo1 bash
bash-5.2#
```

## Fonctionnement du script 💻

### Conditions

La commande `set -e` en début de script permet d’interrompre le script en cas d’erreur. C’est une bonne pratique en scripting bash, étant donné que par défaut bash continuerais l’execution des commandes qui suivent même si une erreur apparaissait.

```bash
if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root" >&2
  exit 1
fi
```

La variable d’environment `EUID` correspond à l’ID de l’user connecté. L’utilisateur `root` à toujours pour EUDI la valeur 0. La condition permet de vérifier que le script est bien lancé en `root`

```bash
if ! grep -q "^12" /etc/debian_version; then
    echo "This script must be run on Debian 12 or a compatible version." >&2
    exit 1
fi
```

Ici je m’assure que le système depuis lequel le script est executé est bien Debian en version 12. La regex `"^12"` permet d’uniquement se baser sur le numéro de version Debian, sans les points derrière :

```bash
root@debian:/home/fabien/exo1/usr/bin# cat /etc/debian_version
12.2
root@debian:/home/fabien/exo1/usr/bin#
```

```bash
if [ "$(lscpu | grep "Architecture:" | awk '{print $2}')" != "x86_64" ]; then
    echo "This script must be run on an x86_64 arch" >&2
    exit 1
fi
```

Enfin, cette condition récupère l’architecture du système en pipant l’output de la commande `lscpu` . J’ai réalisé l’exercice sur une archi x86_64. Si jamais le système n’as pas la bonne architecture, le script se termine.

### Dépendances

Pour être en mesure de savoir de quoi à besoin le programme `msnake` pour fonctionner, j’ai executé cette commande : 

 

```bash
fabien@debian:~/exo1/usr/bin$ ldd msnake
	linux-vdso.so.1 (0x00007fff333f6000)
	libncurses.so.6 => /lib/x86_64-linux-gnu/libncurses.so.6 (0x00007f48cfcf0000)
	libtinfo.so.6 => /lib/x86_64-linux-gnu/libtinfo.so.6 (0x00007f48cfcbd000)
	libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f48cfadc000)
	/lib64/ld-linux-x86-64.so.2 (0x00007f48cfd26000)
fabien@debian:~/exo1/usr/bin$
```

La suite du script copie ces librairies au sein du répertoire `exo1` afin qu’elles puissent être utilisé par `msnake`




💡 La commande `ls` est aussi installée dans le jail, permettant de parcourir l’arborescence.
