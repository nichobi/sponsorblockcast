# sponsorblockcast
A POSIX shell script that skips sponsored Youtube content on all local Chromecasts, using the [SponsorBlock](https://github.com/ajayyy/SponsorBlock) API. It was inspired by [CastBlock](https://github.com/stephen304/castblock) but written from scratch to avoid some of its pitfalls (see [Differences from CastBlock](#differences-from-castblock))

Care was taken to ensure it's fully POSIX-compatible, so it can run on lighter shells such as [Dash](https://wiki.archlinux.org/index.php/Dash).

The script will scan for all Chromecasts on the LAN, and launches a process for each one to efficiently poll it status every second. If a Chromecast is found to be playing a YouTube video, sponsor segments are fetched from the SponsorBlock API and stored in a temporary file. Whenever the Chromecast reaches a sponsored segment, the script tells it to seek to the end of the segment.

## Installation
### Arch Linux
Install [sponsorblockcast-git](https://aur.archlinux.org/packages/sponsorblockcast-git) with your [AUR helper](https://wiki.archlinux.org/index.php/AUR_helpers) of choice or with [makepkg](https://wiki.archlinux.org/index.php/Arch_User_Repository#Installing_and_upgrading_packages).
### Manual installation
#### Dependencies

* [go-chromecast](https://github.com/vishen/go-chromecast)
* [jq](https://stedolan.github.io/jq)
* [bc](https://www.gnu.org/software/bc)
#### Instructions
* Copy [sponsorblockcast.sh](/sponsorblockcast.sh) to `/usr/bin/sponsorblockcast`.
* Copy [sponsorblockcast.service](/sponsorblockcast.service) to `/usr/lib/systemd/system/sponsorblockcast.service`.

## Usage
Run `sponsorblockcast` from a terminal or activate the service with `systemd enable --now sponsorblockcast`

## Configuration
You can configure the following parameters by setting the appropriate enviroment values:
* `SBCPOLLINTERVAL` - Time to wait between each polling of the Chromecasts' status (default=`1`)
* `SBCSCANINTERVAL` - Time to wait between each scan for available Chromecast (default=`300`)
* `SBCDIR` - Directory where temporary files are stored (default=`/tmp/sponsorblockcast`)
* `SBCCATEGORIES` - Space-separated SponsorBlock categories to skip, see [category list](https://github.com/ajayyy/SponsorBlock/blob/master/config.json.example) (default=`sponsor`)

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
```

## Differences from CastBlock
* Regular scans to find new Chromecasts while the script is running
* Allows configuring parameters
* Specify which SponsorBlock categories to skip
* More efficient polling, through using `go-chromecast`'s `watch` command, avoiding expensive startup costs. This lets us poll much more often, without any large performance costs.
* Full POSIX-compatibility

