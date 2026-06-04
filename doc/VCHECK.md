## AUR Checks

```
[vcheck:librewolf-bin_aur_latest]
check: postsed=s#^[0-9]:##!!librewolf-bin!!aur_latest
```

## Latest Checks

```
[vcheck:audiobookshelf_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}$!!docker.io/advplyr/audiobookshelf!!docker_tags_latest

[vcheck:authelia_docker_latest]
check: search=^[0-9]+(\.[0-9]+){2,3}$!!docker.io/authelia/authelia!!docker_tags_latest

[vcheck:bazarr_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}-ls[0-9]+$!!docker.io/linuxserver/bazarr!!docker_tags_latest

#[vcheck:booklore_docker_latest]
#check: search=^v?[0-9]+(\.[0-9]+){2,3}$!!docker.io/booklore/booklore!!docker_tags_latest

[vcheck:bookshelf_docker_latest]
check: search=^softcover-v?[0-9]+(\.[0-9]+){2,3}$!!ghcr.io/pennydreadful/bookshelf!!docker_tags_latest

[vcheck:bookstack_docker_latest]
check: search=v[0-9]+(\.[0-9]+){2,3}-ls[0-9]+$!!docker.io/linuxserver/bookstack!!docker_tags_latest

[vcheck:calibre_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}-ls[0-9]+$!!docker.io/linuxserver/calibre!!docker_tags_latest

[vcheck:calibre-web_docker_latest]
check: remove=-ls1$!!search=^v?[0-9]+(\.[0-9]+){2,3}-ls[0-9]+$!!docker.io/linuxserver/calibre-web!!docker_tags_latest

[vcheck:chronograf_docker_latest]
check: postsed=s#-alpine##!!search=^v?[0-9]+(\.[0-9]+){2,3}$!!docker.io/chronograf!!docker_tags_latest

[vcheck:collabora_docker_latest]
check: remove=(alpha|beta|rc)([0-9]+)?$!!search=^[0-9]+(\.[0-9]+){2,3}$!!docker.io/collabora/code!!docker_tags_latest

[vcheck:dockhand_docker_latest]
check: remove=^[0-9a-f]+$!!search=^v[0-9]+(\.[0-9]+){2,3}$!!docker.io/fnsys/dockhand!!docker_tags_latest

[vcheck:etherpad_docker_latest]
check: search=^[0-9]+(\.[0-9]+){2,3}$!!docker.io/etherpad/etherpad!!docker_tags_latest

[vcheck:feishin_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}$!!ghcr.io/jeffvli/feishin!!docker_tags_latest

[vcheck:flaresolverr_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}$!!docker.io/flaresolverr/flaresolverr!!docker_tags_latest

[vcheck:forgejo_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}$!!codeberg.org/forgejo/forgejo!!docker_tags_latest

[vcheck:forgejo-runner_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}$!!code.forgejo.org/forgejo/runner!!docker_tags_latest

[vcheck:frigate_docker_latest]
check: search=^[0-9]+(\.[0-9]+){2,3}$!!ghcr.io/blakeblackshear/frigate!!docker_tags_latest

[vcheck:giftmanager_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}$!!docker.io/icbest/giftmanager!!docker_tags_latest

[vcheck:gitea_docker_latest]
check: postsed=s#-rootless##!!search=^v?[0-9]+(\.[0-9]+){2,3}-rootless$!!docker.gitea.com/gitea!!docker_tags_latest

[vcheck:gitlab_docker_latest]
check: postsed=s#-ce.*##!!search=^v?[0-9]+(\.[0-9]+){2,3}-ce!!docker.io/gitlab/gitlab-ce!!docker_tags_latest

[vcheck:grafana_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}$!!docker.io/grafana/grafana!!docker_tags_latest

[vcheck:hawser_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}$!!ghcr.io/finsys/hawser!!docker_tags_latest

[vcheck:immich_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}$!!ghcr.io/immich-app/immich-server!!docker_tags_latest

[vcheck:immichframe_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}$!!ghcr.io/immichframe/immichframe!!docker_tags_latest

[vcheck:influxdb_docker_latest]
check: postsed=s#-core##!!search=^v?[0-9]+(\.[0-9]+){2,3}-core$!!docker.io/influxdb!!docker_tags_latest

[vcheck:jackett_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}-ls[0-9]+$!!docker.io/linuxserver/jackett!!docker_tags_latest

[vcheck:jellyfin_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}$!!docker.io/jellyfin/jellyfin!!docker_tags_latest

[vcheck:jellyfin-vue_docker_latest]
check: postsed=s#^stable-rc\.##!!search=^stable-rc.[0-9]+(\.[0-9]+){2,3}$!!docker.io/jellyfin/jellyfin-vue!!docker_tags_latest

[vcheck:jellystat_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}$!!docker.io/cyfershepard/jellystat!!docker_tags_latest

[vcheck:jitsi-excalidraw_docker_latest]
check: search=^[0-9]{4}\.[0-9]+\.[0-9]+$!!docker.io/jitsi/excalidraw-backend!!docker_tags_latest

[vcheck:jitsi-meet_docker_latest]
check: skip_version_filter!!postsed=s#^stable-##!!search=^stable-[0-9]+$!!docker.io/jitsi/web!!docker_tags_latest

[vcheck:kapacitor_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}$!!docker.io/kapacitor!!docker_tags_latest

[vcheck:librespeed_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}$!!ghcr.io/librespeed/speedtest!!docker_tags_latest

[vcheck:librewolf_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}-[0-9]+-ls[0-9]+$!!docker.io/linuxserver/librewolf!!docker_tags_latest

[vcheck:linkding_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}$!!docker.io/sissbruecker/linkding!!docker_tags_latest

[vcheck:linkwarden_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}$!!ghcr.io/linkwarden/linkwarden!!docker_tags_latest

[vcheck:lldap_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}$!!docker.io/lldap/lldap!!docker_tags_latest

[vcheck:localai_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}$!!docker.io/localai/localai!!docker_tags_latest

[vcheck:mariadb_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}$!!docker.io/mariadb!!docker_tags_latest

[vcheck:meilisearch_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}$!!docker.io/getmeili/meilisearch!!docker_tags_latest

[vcheck:memcached_docker_latest]
check: postsed=s#-alpine##!!search=^v?[0-9]+(\.[0-9]+){2,3}-alpine$!!docker.io/memcached!!docker_tags_latest

[vcheck:mollysocket_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}$!!ghcr.io/mollyim/mollysocket!!docker_tags_latest

[vcheck:mosquitto_docker_latest]
check: postsed=s#-alpine##!!search=^v?[0-9]+(\.[0-9]+){2,3}-alpine$!!docker.io/eclipse-mosquitto!!docker_tags_latest

[vcheck:mysql_docker_latest]
check: search=^[0-9]+(\.[0-9]+){2,3}$!!docker.io/mysql/mysql-server!!docker_tags_latest

[vcheck:navidrome_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}$!!docker.io/deluan/navidrome!!docker_tags_latest

[vcheck:nextcloud_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}$!!docker.io/nextcloud!!docker_tags_latest

[vcheck:nginx_docker_latest]
check: postsed=s#-alpine##!!search=^v?[0-9]+(\.[0-9]+){2,3}-alpine$!!docker.io/nginx!!docker_tags_latest

[vcheck:nginx_docker_mainline_latest]
check: search=>mainline<!!presed=s#^.*><code [^>]+">##!!presed=s#</code>,.*$##!!https://hub.docker.com/_/nginx!!curl

[vcheck:ntfy_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}$!!docker.io/binwiederhier/ntfy!!docker_tags_latest

[vcheck:octoprint_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}$!!docker.io/octoprint/octoprint!!docker_tags_latest

[vcheck:ollama_docker_latest]
cache_lifetime: 480
check: search=^[0-9]+(\.[0-9]+){2,3}$!!docker.io/ollama/ollama!!docker_tags_latest

[vcheck:opencloud_docker_latest]
check: search=^[0-9]+(\.[0-9]+){2,3}$!!docker.io/opencloudeu/opencloud-rolling!!docker_tags_latest

[vcheck:open-webui_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}$!!docker.io/openwebui/open-webui!!docker_tags_latest

[vcheck:openregex_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}$!!docker.io/sunnev/openregex!!docker_tags_latest

[vcheck:owncloud_docker_latest]
check: search=^[0-9]+(\.[0-9]+){2,3}$!!docker.io/owncloud/server!!docker_tags_latest

[vcheck:plex_docker_latest]
check: skip_version_filter!!search=^v?[0-9]+(\.[0-9]+){2,3}-[0-9a-f]+$!!docker.io/plexinc/pms-docker!!docker_tags_latest

[vcheck:portainer_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}$!!docker.io/portainer/portainer-ce!!docker_tags_latest

[vcheck:portainer-agent_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}$!!docker.io/portainer/agent!!docker_tags_latest

[vcheck:postgres_docker_latest]
check: search=^v?[0-9]+\.[0-9]+$!!docker.io/postgres!!docker_tags_latest

[vcheck:vchord-postgres_docker_latest]
check: postsed=s#-(arm64|amd64)##!!search=^pg17-v0\.4\.3$!!docker.io/tensorchord/vchord-postgres!!docker_tags_latest

[vcheck:prowlarr_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}-ls[0-9]+$!!docker.io/linuxserver/prowlarr!!docker_tags_latest

[vcheck:qbittorrent_docker_latest]
check: skip_version_filter!!search=^v?[0-9]+(\.[0-9]+){2,3}(-r[0-9]+|_v[0-9]+(\.[0-9]+){2})?-ls[0-9]+$!!docker.io/linuxserver/qbittorrent!!docker_tags_latest

[vcheck:qui_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}$!!ghcr.io/autobrr/qui!!docker_tags_latest

[vcheck:radarr_docker_latest]
check: search=^[0-9]+(\.[0-9]+){2,3}-ls[0-9]+$!!docker.io/linuxserver/radarr!!docker_tags_latest

[vcheck:redis_docker_latest]
check: search=^v?[0-9a-z]+(\.[0-9a-z]+){2,3}$!!docker.io/redis!!docker_tags_latest

[vcheck:registry_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}$!!docker.io/registry!!docker_tags_latest

[vcheck:restic-rest-server_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}$!!docker.io/restic/rest-server!!docker_tags_latest

[vcheck:restreamer_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}$!!docker.io/datarhei/restreamer!!docker_tags_latest

[vcheck:seafile_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}$!!docker.io/seafileltd/seafile-mc!!docker_tags_latest

[vcheck:seerr_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}$!!docker.io/seerr/seerr!!docker_tags_latest

[vcheck:shlink_docker_latest]
check: search=^[0-9]+(\.[0-9]+){2,3}$!!docker.io/shlinkio/shlink!!docker_tags_latest

[vcheck:shlink-web-client_docker_latest]
check: search=^[0-9]+(\.[0-9]+){2,3}$!!docker.io/shlinkio/shlink!!docker_tags_latest

[vcheck:sonarr_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}-ls[0-9]+$!!docker.io/linuxserver/sonarr!!docker_tags_latest

[vcheck:streamystats_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}$!!docker.io/fredrikburmester/streamystats-v2-nextjs!!docker_tags_latest

[vcheck:syncthing_docker_latest]
check: search=^[0-9]+(\.[0-9]+){2,3}$!!docker.io/syncthing/syncthing!!docker_tags_latest

[vcheck:tautulli_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}$!!docker.io/tautulli/tautulli!!docker_tags_latest

[vcheck:telegraf_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}$!!docker.io/telegraf!!docker_tags_latest

[vcheck:traefik_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}$!!docker.io/traefik!!docker_tags_latest

[vcheck:trilium_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}$!!docker.io/triliumnext/trilium!!docker_tags_latest

[vcheck:unifi_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}$!!docker.io/linuxserver/unifi-network-application!!docker_tags_latest

[vcheck:unifi-poller_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}$!!ghcr.io/unpoller/unpoller!!docker_tags_latest

[vcheck:unpackerr_docker_latest]
check: search=^v?[0-9]+(\.[0-9]+){2,3}$!!docker.io/golift/unpackerr!!docker_tags_latest
```

## Source Projects to get latest version

- adguardhome: AdguardTeam/AdGuardHome!!github_latest
- audiobookshelf: advplyr/audiobookshelf!!github_latest
- authelia: authelia/authelia!!github_latest
- bazarr: morpheus65535/bazarr!!github_latest
- booklore: booklore-app/booklore!!github_latest
- bookstack: bookstackapp/bookstack!!github_latest
- calibre: kovidgoyal/calibre!!github_latest
- calibre_ls: linuxserver/docker-calibre!!github_latest
- calibre-web: janeczku/calibre-web!!github_latest
- calibre-web_ls: linuxserver/docker-calibre-web!!github_latest
- chezmoi: twpayne/chezmoi!!github_latest
- chronograf: influxdata/chronograf!!github_latest
- decode-config: tasmota/decode-config!!github_latest
- docker-compose: docker/compose!!github_latest
- dockhand: finsys/dockhand!!github_latest
- etherpad: ether/etherpad!!github_latest
- feishin: jeffvli/feishin!!github_latest
- [flaresolverr](https://raw.githubusercontent.com/21hsmw/flaresolverr/refs/heads/nodriver-support/changelog.md):
  flaresolverr/flaresolverr!!github_latest
- flip-2-dnd: robinsrk/flip_2_dnd!!github_latest
- forgejo: forgejo/forgejo!!codeberg_latest
- forgejo-runner: forgejo/runner!!forgejo_latest
- frigate: blakeblackshear/frigate!!github_latest
- giftmanager: icbestca/giftmanager!!github_latest
- gitea: go-gitea/gitea!!github_latest
- grafana: grafana/grafana!!github_latest
- hawser: finsys/hawser!!github_latest
- immichframe: immichframe/immichframe!!github_latest
- immich: immich-app/immich!!github_latest
- influxdb: influxdata/influxdb!!github_latest
- jackett: linuxserver/docker-jackett!!github_latest
- jellyfin: jellyfin/jellyfin!!github_latest
- jellystat: cyfershepard/jellystat!!github_latest
- jitsi-excalidraw: jitsi/excalidraw-backend!!github_latest
- jitsi-meet: jitsi/jitsi-meet!!github_latest
- joplin: laurent22/joplin!!github_latest
- kapacitor: influxdata/kapacitor!!github_latest
- librespeed: librespeed/speedtest!!github_latest
- librewolf: librewolf/source!!codeberg_latest
- librewolf_ls: linuxserver/docker-librewolf!!github_latest
- linkding: sissbruecker/linkding!!github_latest
- linkwarden: linkwarden/linkwarden!!github_latest
- lldap: lldap/lldap!!github_latest
- mariadb: mariadb/server!!github_latest
- meilisearch: meilisearch/meilisearch!!github_latest
- mollysocket: mollyim/mollysocket!!github_latest
- naemon: naemon/naemon-core!!github_latest
- nagios: nagiosenterprises/nagioscore!!github_latest
- navidrome: navidrome/navidrome!!github_latest
- nginx: nginx/nginx!!github_latest
- ntfy: binwiederhier/ntfy!!github_latest
- octoprint: octoprint/octoprint!!github_latest
- ollama: ollama/ollama!!github_latest
- opencloud: opencloud-eu/opencloud!!github_latest
- opensmtpd: OpenSMTPD/OpenSMTPD!!github_latest
- pagefind: Pagefind/pagefind!!github_latest
- php: php/php-src!!github_latest
- pihole: pi-hole/pi-hole!!github_latest
- portainer: portainer/portainer!!github_latest
- pot-provider: Brainicism/bgutil-ytdlp-pot-provider!!github_latest
- privatebin: privatebin/privatebin!!github_latest
- proton-ge: gloriouseggroll/proton-ge-custom!!github_latest
- prowlarr: linuxserver/docker-prowlarr!!github_latest
- putty-cac: nomorefood/putty-cac!!github_latest
- qbittorrent: linuxserver/docker-qbittorrent!!github_latest
- qui: autobrr/qui!!github_latest
- radarr: linuxserver/docker-radarr!!github_latest
- rclone: rclone/rclone!!github_latest
- redis: redis/redis!!github_latest
- registry: distribution/distribution!!github_latest
- restic: restic/restic!!github_latest
- restic-rest-server: restic/rest-server!!github_latest
- restreamer: datarhei/restreamer!!github_latest
- rofi-rbw: fdw/rofi-rbw!!github_latest
- seerr: seerr-team/seerr!!github_latest
- shlink: shlinkio/shlink!!github_latest
- shlink-web: shlinkio/shlink!!github_latest
- snapcast: snapcast/snapcast!!github_latest
- sonarr: linuxserver/docker-sonarr!!github_latest
- splunk-unix-ta: merdely/TA-unix!!github_latest
- streamystats: fredrikburmester/streamystats!!github_latest
- syncthing: syncthing/syncthing!!github_latest
- tasmota: arendst/tasmota!!github_latest
- tautulli: tautulli/tautulli!!github_latest
- telegraf: influxdata/telegraf!!github_latest
- tmux: tmux/tmux!!github_latest
- traefik: traefik/traefik!!github_latest
- trilium: triliumnext/trilium!!github_latest
- unifi: linuxserver/docker-unifi-network-application!!github_latest
- unifi-poller: unpoller/unpoller!!github_latest
- unpackerr: unpackerr/unpackerr!!github_latest
- vscode-web: coder/code-server!!github_latest
- vscodium: vscodium/vscodium!!github_latest
- wleave: amnatty/wleave!!github_latest
- yourls: yourls/yourls!!github_latest
- zigbee2mqtt: koenkk/zigbee2mqtt!!github_latest
- zwave-js: zwave-js/zwave-js-ui!!github_latest

## Command Checks are defined then as ${package}_command (or /usr/local/bin/program/command

- decode-config
- chezmoi
- forgejo-runner
- librewolf
- rclone
- rofi-rbw
- snapclient
- snapserver
- tmux

## Pacman Package Checks are defined then as ${package}_pacman

- archiso-systemd-boot
- c++utilities
- dbeaver-ce-bin
- electron28-bin
- grayjay-bin
- libpam-pwdfile-rs-bin
- libratbag-git
- librewolf
- librewolf-bin
- lisgd
- logseq-desktop-bin
- molly-guard-git
- mqtt5-explorer-bin
- ntfysh-bin
- oscar
- pinta
- pipeline-gtk
- piper-git
- qtforkawesome-qt6
- qtutilities-qt6
- syncthingtray-qt6
- ungoogled-chromium-bin
- waybar-updates
- wleave
- zoom

# AUR Checks

- librewolf-bin : `postsed=s#^[0-9]:##!!librewolf-bin!!aur_latest`

## Docker printenv checks: <container>!!<variable>!!docker_printenv

- `chronograf!!CHRONOGRAF_VERSION!!docker_printenv`
- `influxdb!!INFLUXDB_VERSION!!docker_printenv`
- `kapacitor!!KAPACITOR_VERSION!!docker_printenv`
- `mosquitto!!VERSION!!docker_printenv`
- `nextcloud!!NEXTCLOUD_VERSION!!docker_printenv`
- `postgres!!PG_VERSION!!docker_printenv`
- `seafile!!SEAFILE_VERSION!!docker_printenv`
- `telegraf!!TELEGRAF_VERSION!!docker_printenv`

## docker_inspect checks : run like <container_project>!!docker_inspect projects:

- audiobookshelf
- authelia
- bazarr
- booklore
- bookstack
- calibre
- calibre-web
- collabora
- etherpad
- fcgiwrap
- feishin
- flaresolverr
- forgejo
- forgejo-runner
- hawser
- immich-kiosk
- immichframe
- immich-server
- jackett
- jellyfin
- jitsi-excalidraw (`jitsi/excalidraw-backend!!docker_inspect`)
- jitsi-meet  (`postsed=s#^stable-##!!jitsi/web!!docker_inspect`)
- librewolf
- linkwarden
- lldap
- localai
- mariadb
- meilisearch
- navidrome
- naemon
- nginx
- php-fpm
- prowlarr
- qbittorrent
- qui
- radarr
- seerr
- shlink
- shlink-web-client
- sonarr
- syncthing
- traefik
- trilium
- unifi-poller
- unpackerr
- vchord-postgres
- whoami

## Github Tags

- fcgiwrap - `remove=^v!!gnosek/fcgiwrap!!github_tags`
- jellyfin-vue - `jellyfin/jellyfin-vue!!github_tags`
- memcached - `search=^[0-9]+(\.[0-9]+){2,3}$!!memcached/memcached!!github_tags`
- mosquitto - `eclipse-mosquitto/mosquitto!!github_tags`
- mysql - `search=^mysql-[0-9]+(\.[0-9]+){2,3}$!!mysql/mysql-server!!github_tags`
- openregex - `SunneV/OpenRegex!!github_tags`
- open-webui - `open-webui/open-webui!!github_tags`
- opnsense - `search=^[0-9]+(\.[0-9]+){2,3}$!!opnsense/core!!github_tags`
- owncloud - `search=^v[0-9]+(\.[0-9]+){2,3}$!!owncloud/core!!github_tags`
- postgres - `postsed=s#_#.#g!!search=^REL_[0-9]+_[0-9]+$!!postgres/postgres!!github_tags`
- rsyslog - `rsyslog/rsyslog!!github_tags`
- seafile - `postsed=s#-server$##!!search=^v[0-9]+(\.[0-9]+){2,3}-server$!!haiwen/seafile-server!!github_tags`
- opensmtpd - `postsed=s#p[0-9]+$##!!search=^[0-9]+(\.[0-9]+){2,3}(p[0-9]+)?$!!OpenSMTPD/OpenSMTPD!!github_tags`
- tasmobackup - `danmed/TasmoBackupV1!!github_tags`
- thruk - `sni/thruk!!github_tags`

## Docker Exec Checks

- frigate: `postsed=s#-[0-9a-zA-Z]+##!!frigate!!/usr/bin/cat /opt/frigate/frigate/version.py!!docker_exec`
The '/usr/bin/' part of the above check is only to demonstrate how to use a full path
- giftmanager: `search=app_version!!giftmanager!!cat /app/app.py!!docker_exec`
- gitea: `gitea!!gitea --version!!docker_exec`
- gitlab: `search=gitlab-ce!!gitlab!!cat /opt/gitlab/version-manifest.txt!!docker_exec`
- grafana: `search=Version [0-9]!!grafana!!grafana-server -v!!docker_exec`
- jellyfin: `postsed=s#Jellyfin\.Server ##!!postsed=s#\.[0-9]$##!!jellyfin!!/jellyfin/jellyfin --version!!docker_exec`
- jellystat: `prejq=.version!!jellystat!!wget -qO- http://127.0.0.1:3000/auth/isconfigured!!docker_exec`
- linkding: `linkding!!cat /etc/linkding/version.txt!!docker_exec`
- localai: `localai!!/local-ai --version!!docker_exec`
- mariadb: `postsed=s#-MariaDB.*$##!!mariadb!!mariadbd -V!!docker_exec`
- meilisearch: `meilisearch!!meilisearch -V!!docker_exec`
- memcached: `memcached!!memcached --version!!docker_exec`
- mollysocket: `mollysocket!!mollysocket -V!!docker_exec`
- mysql: `mysql!!mysqld -V!!docker_exec`
- naemon: `naemon!!naemon --version!!docker_exec`
- my_nagios_docker: `nagios!!cat /etc/versions/nagios.txt!!docker_exec`
- nginx: `nginx!!nginx -V!!docker_exec`
- ntfy: `search=^ntfy [0-9]!!ntfy!!ntfy --help!!docker_exec`
- octoprint: `octoprint!!octoprint --version!!docker_exec`
- ollama: `ollama!!ollama --version!!docker_exec`
- opencloud: `search=^Version:!!opencloud!!opencloud version!!docker_exec`
- openregex: `search=^## \[[0-9]!!remove=-dev\]!!openregex!!cat /app/CHANGELOG.md!!docker_exec`
- owncloud: `search=\$OC_VersionString[[:space:]]*=!!owncloud!!cat /var/www/owncloud/version.php!!docker_exec`
- open-webui: `prejq=.version!!open-webui!!cat /app/package.json!!docker_exec`  
- php_fpm_docker: `search=^php85-common!!php-fpm!!apk list --installed!!docker_exec`
- portainer_docker: `portainer!!/portainer --version!!docker_exec`
- portainer_agent_docker: `search=Portainer-Agent!!portainer_agent!!wget --no-check-certificate -qSO- https://127.0.0.1:9001/ping!!docker_exec`
- pot-provider: `prejq=.version!!pot-provider!!cat /app/package.json!!docker_exec`
- rsyslog_docker: `rsyslog!!rsyslogd -v!!docker_exec`
- seerr: `prejq=.version!!seerr!!cat /app/package.json!!docker_exec`
- streamystats: `prejq=.version!!streamystats!!cat /app/package.json!!docker_exec`
- tautulli: `search=PLEXPY_RELEASE_VERSION!!tautulli!!cat /plexpy/version.py!!docker_exec`
- thruk: `thruk!!thruk --version!!docker_exec`
- unifi: `unifi!!cat /usr/lib/unifi/data/db/version!!docker_exec`
- upmpdcli: `upmpdcli!!upmpdcli -v!!docker_exec`

## Cat file Checks

- example: `/path/to/file.txt/cat`
- using progdata: `$PROGDATA/file.txt!!cat`
- splunk: `search=^VERSION!!/opt/splunk/etc/splunk.version!!cat`
- splunk_forwarder: `search=^VERSION!!/opt/splunkforwarder/etc/splunk.version!!cat`
- zwave_js: `postsed=s#.*Version: ##!!search=INFO.* .*(APP|STORE).*: Version:!!/var/log/zwave.out!!cat`

## Alpine Repo Package

- fcgiwrap - `fcgiwrap!!alpine_repo_latest`
- nginx - `nginx!!alpine_repo_latest`
- php - `php85-common!!alpine_repo_latest`

## Curl API Checks

- adguardhome_server - `prejq=.version!!adguardhome_server!!curlapi`
- local flip_2_dnd_pro mirror - `prejq=.[].tag_name!!flip_2_dnd_pro!!curlapi`
- joplin_server - `search=Joplin Server [0-9]!!postsed=s#^#server-v#!!joplin!!curlapi`
- opnsense_device - `postsed=s#-[a-z][a-z0-9]+$##!!search=^OPNsense!!prejq=.versions[]!!opnsense_device!!curlapi`
- plex_docker - `search=^<MediaContainer!!plex!!curlapi`  # untested
- routeros_device - `prejq=.[] | select(.name=="routeros")|.version!!routeros_device!!curlapi`
- slzb_core - `prejq=.Info.sw_version!!slzb_core!!curlapi`
- slzb_radio - `skip_version_filter!!prejq=.Info.zb_version!!slzb_radio!!curlapi`
- tasmota_device - `prejq=.StatusFWR.Version!!tasmota_device!!curlapi`
- truenas_server - `prejq=.!!truenas_server!!curlapi`

## Curl Checks

- empiretech_camera: `xml=//div[@class="firmwares_content_container"]/div[1][contains(text(), "IPC-Color4K-T-S2")]/following-sibling::div[2]/text()!!https://empiretech01.com/pages/download-firmwares!!curl`
- ffprobe_latest: `search=<th>release:!!https://johnvansickle.com/ffmpeg/!!curl`
- filestash_latest: `search=APP_VERSION!!https://raw.githubusercontent.com/mickael-kerjean/filestash/refs/heads/master/server/common/constants.go!!curl`
- librewolf_homebrew: `check: search=Current version:!!postsed=s#^.*<a .*">##!!postsed=s#,([0-9]+)#-\1#!!https://formulae.brew.sh/cask/librewolf#default!!curl`
- molly_guard_latest: `search=<title>debian!!presed=s#^.*<title>debian/##!!presed=s#</title>##!!https://salsa.debian.org/debian/molly-guard/-/tags?format=atom!!curl`
- nextcloud: `search=/download\.nextcloud\.com/server/releases/nextcloud-.*\.tar\.bz2<!!presed=s#^.*>nextcloud-##!!presed=s#\.tar\.bz2.*##!!https://nextcloud.com/changelog/!!curl`
- plex: `prejq=.["computer"]["Linux"].version!!https://plex.tv/pms/downloads/5.json?channel=plexpass!!curl`
- privatebin: `search=<p class="col-md-1 col-xs-4 text-center">[^<]+</p>!!presed=s#^.*">##!!presed=s#</p>##!!https://privatebin.example.com!!curl`
- routeros: `search=<title>RouterOS [0-9]!!https://cdn.mikrotik.com/routeros/latest-stable.rss!!curl`
- seafile_client_appimage_latest: `search=Seafile-x86_64!!presed=s#^.*">##!!presed=s#</a>.*$##!!https://www.seafile.com/en/download/!!curl`
- slzb_core_latest: `prejq=.["fw"][]|select(.dev==false)|.ver!!remove=\.dev.*$!!https://updates.smlight.tech/services/api/slzb-06x-ota.php?type=ESP!!curl`  
  type=ESP (0=ESP vs ESPs3 for type>SLZB_06MR4[14])
- slzb_radio_latest: `skip_version_filter!!prejq=.[0][]|select(.type=="0")|.rev!!https://updates.smlight.tech/services/api/slzb-06x-ota.php?type=ZB&format=slzb!!curl`  
   chip=0 (slzb-06p10 (CC2652P), type=0 (coordinator)
- splunk_enterprise: `search=<span class="version">!!https://www.splunk.com/en_us/download/splunk-enterprise.html!!curl`
- splunk_forwarder: `search=<span class="version">!!https://www.splunk.com/en_us/download/universal-forwarder.html!!curl`
- splunk_unix_ta: `search=">Latest Version[^<]+<!!presed=s#^.*<div [^>]+">Latest Version ##!!https://splunkbase.splunk.com/app/833!!curl`
- tasmobackup: `search=>TasmoBackup .+ by Dan Medhurst<!!http://127.0.0.1:8259!!curl`
- truenas: `prejq=.version!!https://update.sys.truenas.net/scale/TrueNAS-SCALE-ElectricEel/manifest.json?download=1!!curl`
- yourls: `https://yourls.tld/ver.php!!curl`  
  Create a ver.php in the root of yourls with:
  ```
  <?php
  require_once( dirname(__FILE__).'/includes/load-yourls.php' );
  print("{\n  \"version\": \"" . YOURLS_VERSION . "\"\n}\n");
  ?>
  ```

## Git Describe

- libratbag: `skip_version_filter!!https://github.com/libratbag/libratbag.git!!gitdescribe`
- piper: `skip_version_filter!!postsed=s#([^-]*-g)#r\1#!!postsed=s#-#.#g!!https://github.com/libratbag/piper.git!!gitdescribe`

## Git Tags

- putty: `search=^[0-9]+(\.[0-9]+){1,2}$!!https://git.tartarus.org/simon/putty.git!!gittags`

## AppImage Checks

- Joplin: `Joplin!!appimage`
- Seafile: `Seafile!!appimage`

## Docker Copy Checks

- Dockhand: 'search=^const [a-z][a-z0-9A-Z_]*=JSON.parse\(`!!dockhand!!/app/build/server/chunks!!chunks/*.js!!docker_copy'
- Restreamer: `search=restreamer-v!!postsed=s#^.*:"restreamer-(v[^"]+)".*$#\1#!!restreamer!!/core/ui/static/js!!js/main.*.js!!docker_copy`

## Docker Logs Checks

- pihole: `search=Pi-hole version is v[0-9]!!pihole!!docker_logs`
- docker registry: `search=registry version=v!!presed=s#service=registry version=v##!!registry!!docker_logs`
- vscode: `search=\] info code-server [0-9]!!vscode!!docker_logs`
- zigbee2mqtt: `search=Starting Zigbee2MQTT version!!zigbee2mqtt!!docker_logs`
