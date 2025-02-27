# Vypracovaný úkol pro CDN77

Tento repozitář slouží pro vypracování a version control úkolu pro CDN77.
Celý text zadání je k nalezení v adresáři `zadani`.

---

Toto řešení implikuje, že ~~testovací server má spuštěné **sshd** na portu 22,~~ uživatel, pod kterým se test spouští má nastavený **keyless root** v `/etc/sudoers` ~~a ssh klíč v `authorized_keys`~~.
Zároveň předpokládá, že je k dispozici python3 a python3-pip.
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

## 20240220 - První kroky:

Pročetl jsem zadání a zprvu působilo vcelku srozumitelně, po bližším prozkoumání Ansible a pročtení části dokumentace jsem se rozhodl, že mi nepřijde smysluplné jej přeskakovat, ale naopak se s ním do hloubky seznámit.
Vzhledem k tomu, že mám zkušenosti s Dockerem, rozhodl jsem se jej použít pro realizaci.
Původně jsem počítal s tím, že bych celou síť včetně control node provozoval jako samostané docker kontejnery běžící na [debian image](https://hub.docker.com/_/debian), abych co nejvěrněji simuloval nevirtualizované prostředí.
Na konci zadání jsem ale narazil na požadavek automatizace vytvoření celé infrastruktury, což tento způsob řešení poněkud zkomplikoval, tedy alespoň za předpokladu, že testovací server bude, jak jsem pochopil, zároveň sloužit jako control node.
Jako řešení jsem tedy zvolil pomocí Ansible na localhostu zprovoznit i samotný docker daemon, zpřistupnit jej pod UDS `/var/run/docker.sock`, a s pomocí `community.docker` pak spustit jednotlivé kontejnery.

## 20240224 - Sestavení inventáře a prvního playbooku

Po detailnějším pročtení dokumentace Ansible jsem se jal připravit první playbook, který by měl obsluhovat instalaci prerekvizit na hostitelském zařízení, tedy zároveň na control node.
Sestavení prvního playbooku a inventáře nebylo nikterak složité, po připravení prostředí (~~nainstalování sshd, vytvoření klíčů a~~ nastavení keyless rootu) jsem vytvořil první Play, zatím jen s jedním krokem - a sice nainstalování Docker daemonu.

Jako modul po instalaci, vzhledem k tomu, že vypracování provádím na distribuci Arch Linux, nikoliv Debian, jsem zvolil `ansible.builtin.package`, která je podle dokumentace univerzální napříč distribucemi.

Spuštění playbooku v kořenovém adresáři provádím následujícím příkazem:
`ansible-playbook playbooks/setup_local.yaml -i ./inventory/inventory.yaml`

Doposud se všechno jevilo vcelku přímočaře, avšak zde jsem narazil na první chybu:
`fatal: [local]: FAILED! => {"msg": "Timeout (12s) waiting for privilege escalation prompt: "}`

Po několika minutách v dokumentaci jsem však přišel na to, že jsem kromě `become: true` nastavil i `become_user: root`, což zjevně způsobilo zmíněný password prompt.
Po odstranění `become_user: root` instalace docker daemonu proběhla v pořádku.

Po instalaci a spuštění docker daemonu jsem se pokoušel přidal uživatele spouštějícího playbook do skupiny `docker`, pro omezení dalších eskalací oprávnění - zbytek akcí se provádí přímo v Docker daemonu ~~, nebo pomocí SSH připojení~~ pomocí [community.docker.docker_api](https://ansible-collections.github.io/community.docker/branch/main/docker_api_connection.html#ansible-collections-community-docker-docker-api-connection).

Zde jsem použil první proměnnou, a sice `{{ ansible_user_id }}` odpovídající uživateli spouštějícímu playbook.
Taktéž jsem se setkal s modulem `ansible.builtin.debug`, který jsem použil pro oveření, zda při `become: true` proměnná vrací správnou hodnotu.

Tento krok rozhodně nebyl nutný a trochu mě při práci zbrzdil, protože jsem mimo jiné narazil na to, že s `connection: local` nelze efektivně použít skupnu nově přiřazenou uživateli, protože vše probíhá v aktuální session.
Monžosti tedy byly dvě:
1. zahodit `connection: local` a pracovat dále s SSH připojením na localhost
2. ke všem zbylým lokálním docker-related taskům připisovat `become: true`
3. ačkoliv nejde o best practice, změnit vlastníka `/var/run/docker.sock` na aktuálního uživatele

Rozhodl jsem se pro třetí možnost, protože mi ušetří práci a při testování úkolu ušetří setup na testovacím serveru. 

---

## 20240221 - Ansible + Docker

Po nainstalování všech dependencí jsem konečně mohl přistoupit ke spuštění docker kontejnerů (prozatím pouze nginx).
Modul [community.docker.docker_container](https://docs.ansible.com/ansible/latest/collections/community/docker/docker_container_module.html) byl poměrně přímočarý a spuštění kontejnerů proběhlo bez větších problémů.

Narazil jsem ale na problém zachování idempotence při použití [čistého debian obrazu](https://hub.docker.com/_/debian) z docker hubu, protože jediný způsob, jak nainstalovat python interpreter na vytvořené kontejnery, byl použít `community.docker.docker_cotainer_exec`.
Rozhodl jsem se proto použít image [python:3.14.0a5-slim-bookworm](https://hub.docker.com/_/python/).
Abych si dále ušetřil práci s nastavování SSH daemonů na jednotlivých kontejnerech, použil jsem v `inventory\inventory.yaml` místo SSH připojení connection plugin [community.docker.docker_api](https://ansible-collections.github.io/community.docker/branch/main/docker_api_connection.html#ansible-collections-community-docker-docker-api-connection).

Další akce prováděné na kontejnerech pak bylo možné provádět stejně, jako s SSH připojením.
Instalaci balíčku a spuštění služby jsem si vyzkoušel již během sestavování prvního playbooku, tedy zde nebyl žádný problém.

Posledním krokem bylo nakopírování konfiguračního souboru pro nginx do proxy node pomocí [ansible.builtin.copy](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/copy_module.html) a reload konfigurace pomocí [ansible.builtin.command](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/command_module.html). Tento postup jsem zvolil místo `state: restarted`, protože nezpůsobuje výpadek připojení potenciálních klientů (ačkoliv v tomto případě žádní nejsou).
Kontejner **nginx-proxy** jsem zpřístupnil přes bridge network na [localhost:80](http://localhost).

---

## ADD_DATE - Apache Kafka

