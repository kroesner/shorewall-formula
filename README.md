# Shorewall Salt Formula
Install and configure [shorewall](http://shorewall.org/) directly with SaltStack.

## Available states

* `shorewall` : Installs and configures `shorewall` distribution package

## Available pillars

You can take a loot at [`pillar.example`](/pillar.example) to configure Shorewall with pillars.

* Default is to install and configure shorewall for ipv4. If ipv6 is needed it must be configured in pillar.
* Each config item (zone, interface, rule, etc.) is configured for all configured ip versions (ipv4, ipv6) by default. If it is needed for one specific version this can be set in pillar with flag 'ipv': 'ipv: 4' or 'ipv: 6'.
