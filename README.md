# Archived
`sponsorblockcast` has been superseded by [CastSponsorSkip](https://github.com/gabe565/CastSponsorSkip), written by [gabe565](https://github.com/gabe565).
I recommend moving over to it for improved performance and privacy.
`sponsorblockcast` will no longer be maintained.

# sponsorblockcast
A POSIX shell script that skips sponsored YouTube content and skippable ads on all local Chromecasts, using the [SponsorBlock](https://github.com/ajayyy/SponsorBlock) API. It was inspired by [CastBlock](https://github.com/stephen304/castblock) but written from scratch to avoid some of its pitfalls (see [Differences from CastBlock](#differences-from-castblock)).

Care was taken to ensure it's fully POSIX-compatible, so it can run on lighter shells such as [Dash](https://wiki.archlinux.org/index.php/Dash).

The script will scan for all Chromecasts on the LAN, and launches a process for each one to efficiently poll it status every second. If a Chromecast is found to be playing a YouTube video, sponsor segments are fetched from the SponsorBlock API and stored in a temporary file. Whenever the Chromecast reaches a sponsored segment, the script tells it to seek to the end of the segment.

Additionally, sponsorblockcast will look for skippable YouTube ads, and automatically hit the skip button when it becomes avilable.

## Installation
### Arch Linux
Install [sponsorblockcast-git](https://aur.archlinux.org/packages/sponsorblockcast-git) with your [AUR helper](https://wiki.archlinux.org/index.php/AUR_helpers) of choice or with [makepkg](https://wiki.archlinux.org/index.php/Arch_User_Repository#Installing_and_upgrading_packages).

### Docker image
You can [install Docker](https://docs.docker.com/engine/install/) directly or use [Docker Compose](https://docs.docker.com/compose/install/) (Or use Podman, Portainer, etc). Please note you *MUST* use the 'host' network as shown below for CLI Docker or in the example for `docker-compose`.

#### Docker
Run the below commands as root or a member of the `docker` group
* `docker run --network=host --name sponsorblockcast ghcr.io/nichobi/sponsorblockcast:latest`

#### Docker Compose
First you will need a `docker-compose.yaml` file, such as the example included. Run the below commands as root or a member of the `docker` group
* `docker-compose up -d`

### Manual installation
#### Dependencies

* [go-chromecast](https://github.com/vishen/go-chromecast)
* [jq](https://stedolan.github.io/jq)
* [bc](https://www.gnu.org/software/bc)
#### Instructions
* Copy [sponsorblockcast.sh](/sponsorblockcast.sh) to `/usr/bin/sponsorblockcast`.
* Copy [sponsorblockcast.service](/sponsorblockcast.service) to `/usr/lib/systemd/system/sponsorblockcast.service`.

## Usage
Run `sponsorblockcast` from a terminal or activate the service with `systemctl enable --now sponsorblockcast`

## Configuration
You can configure the following parameters by setting the appropriate environment values:
* `SBCPOLLINTERVAL` - Time to wait between each polling of the Chromecasts' status (default=`1`)
* `SBCSCANINTERVAL` - Time to wait between each scan for available Chromecast (default=`300`)
* `SBCDIR` - Directory where temporary files are stored (default=`/tmp/sponsorblockcast`)
* `SBCCATEGORIES` - Space-separated SponsorBlock categories to skip, see [category list](https://github.com/ajayyy/SponsorBlock/blob/master/config.json.example) (default=`sponsor`)
* `SBCYOUTUBEAPIKEY` - [YouTube API key](https://developers.google.com/youtube/registering_an_application) for fallback video identification (required on some Chromecast devices).

To run from the terminal with custom parameters you can use `env` like so:
`env SBCSCANINTERVAL=10 SBCPOLLINTERVAL=100 SBCCATEGORIES="sponsor selfpromo" sponsorblockcast`

To modify the variables when running as a systemd service, create an override for the service with:

`sudo systemctl edit sponsorblockcast.service`

This will open a blank override file where you can specify Environment values like so:
```
[Service]
Environment="SBCPOLLINTERVAL=10"
Environment="SBCSCANINTERVAL=100"
Environment="SBCCATEGORIES=sponsor selfpromo"
Environment="SBCYOUTUBEAPIKEY=<your private API key>"
```

To modify the variables when running as a Docker container, you can add arguments to the `docker run` command like so:

`docker run --network=host --env SBCPOLLINTERVAL=10 --env SBCSCANINTERVAL=100 --name sponsorblockcast sponsorblockcast:latest`

When using `docker-compose.yaml` you can simply edit the `environment` directive as shown in the example file.

## Differences from CastBlock
* Regular scans to find new Chromecasts while the script is running
* Allows configuring parameters
* Specify which SponsorBlock categories to skip
* More efficient polling, through using `go-chromecast`'s `watch` command, avoiding expensive startup costs. This lets us poll much more often, without any large performance costs.
* Full POSIX-compatibility

