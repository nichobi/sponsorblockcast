# sponsorblockcast
A POSIX shell script that skips sponsored Youtube content on all local Chromecasts, using the [SponsorBlock](https://github.com/ajayyy/SponsorBlock) API. It was inspired by [castblock](https://github.com/stephen304/castblock) but written from scratch to avoid some of its pitfalls.

Care was taken to ensure it's fully POSIX-compatible, so it can run on lighter shells such as [Dash](https://wiki.archlinux.org/index.php/Dash).

The script will scan for all Chromecasts on the LAN (rescanning every 5 minutes), and then checks their status every 30 seconds. If a Chromecast is playing a YouTube video, sponsor segments are fetched from the SponsorBlock API and stored in a temporary file. Whenever the Chromecast reaches a sponsored segment, the script tells it to seek to the end of it. If the Chromecast is almost at a sponsored segment, the waiting time is reduced so we'll hopefully catch it right at the start of the segment.

## Installation
### Dependencies
* go-chromecast
* jq
* bc

### Manual installation
* Copy [sponsorblockcast.sh](/sponsorblockcast.sh) to `/usr/bin/sponsorblockcast`.
* Copy [sponsorblockcast.service](/sponsorblockcast.service) to `/usr/lib/systemd/system/sponsorblockcast.service`.

## Usage
Run `sponsorblockcast` from a terminal or activate the service with `systemd enable --now sponsorblockcast`
