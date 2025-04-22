# Vypracovaný úkol pro CDN77

Tento repozitář slouží pro vypracování a version control úkolu pro CDN77.
Celý text zadání je k nalezení v adresáři `zadani`.
Vypracování není kompletní.

---

Toto řešení implikuje, že ~~testovací server má spuštěné **sshd** na portu 22,~~ uživatel, pod kterým se test spouští má nastavený **keyless root** v `/etc/sudoers` ~~a ssh klíč v `authorized_keys`~~.
Zároveň předpokládá, že je k dispozici python3 a python3-pip. Předpokládaná verza ansible-core je **2.17.9**.
Pro jednoduchost opomíjí Execution Environment a spoléhá se na instalaci ostatních prerekvizit pomocí lokálního playbooku.

Použité zdroje:
 - (https://docs.ansible.com)
 - Místy (https://stackoverflow.com)

Použitý software:
 - ansible
 - docker
 - nano
 - git

---

