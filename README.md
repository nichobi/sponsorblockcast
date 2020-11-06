# sponsorblockcast
A POSIX shell script that skips sponsored Youtube content on all local Chromecasts, using the [SponsorBlock](https://github.com/ajayyy/SponsorBlock) API. It was inspired by [CastBlock](https://github.com/stephen304/castblock) but written from scratch to avoid some of its pitfalls (see [Differences from CastBlock](#differences-from-castblock))

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

## Configuration
You can configure the following parameters by setting the appropriate enviroment values:
* `SCBPOLLINTERVAL` - Time to wait between checking Chromecast status (default=`30`)
* `SCBSCANINTERVAL` - Time to wait between each scan for available Chromecast (default=`300`)
* `SCBDIR` - Directory where temporary files are stored (default=`/tmp/sponsorblockcast`)

To run from the terminal with custom parameters you can use `env` like so:
`env SCBSCANINTERVAL=10 SCBPOLLINTERVAL=100 sponsorblockcast`

To modify the variables when running as a systemd service, create an override for the service with:  
`sudo systemctl edit sponsorblockcast.service`  
This will open a blank override file where you can specify Environment values like so:
```
[Service]
Environment="SCBPOLLINTERVAL=10"
Environment="SCBSCANINTERVAL=100"
```

## Differences from CastBlock
* Regular scans to find new Chromecasts while the script is running
* Allows configuring parameters
* If a Chromecast is found to be less than one poll interval away from a sponsor segment, the poll interval is temporarily lowered to wake up just as the Chromecast reaches the segment.
* Full POSIX-compatibility

