#!/usr/bin/perl -w
##
## //
## //  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
## //  Copyright © 2023 Two Factor Authentication Service, Inc.
## //  Contributed by Zbigniew Cisiński. All rights reserved.
## //
## //  This program is free software: you can redistribute it and/or modify
## //  it under the terms of the GNU General Public License as published by
## //  the Free Software Foundation, either version 3 of the License, or
## //  any later version.
## //
## //  This program is distributed in the hope that it will be useful,
## //  but WITHOUT ANY WARRANTY; without even the implied warranty of
## //  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## //  GNU General Public License for more details.
## //
## //  You should have received a copy of the GNU General Public License
## //  along with this program. If not, see <https://www.gnu.org/licenses/>
## //
##

use strict;

my $out = "en.lproj/Acknowledgements.strings";
my $plistout =  "Acknowledgements.plist";

unlink $out;

open(my $outfh, '>', $out) or die $!;
open(my $plistfh, '>', $plistout) or die $!;

print $plistfh <<'EOD';
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>StringsTable</key>
<string>Acknowledgements</string>
<key>PreferenceSpecifiers</key>
<array>
EOD
for my $i (sort glob("./Licenses/*.license"))
{
my $value=`cat $i`;
$value =~ s/\r//g;
$value =~ s/\n/\r/g;
$value =~ s/[ \t]+\r/\r/g;
$value =~ s/\"/\'/g;
my $key=$i;
$key =~ s/\.license$//;

my $cnt = 1;
my $keynum = $key;
for my $str (split /\r\r/, $value)
{
print $plistfh <<"EOD";
<dict>
<key>Type</key>
<string>PSGroupSpecifier</string>
<key>FooterText</key>
<string>$keynum</string>
</dict>
EOD

print $outfh "\"$keynum\" = \"$str\";\n";
$keynum = $key.(++$cnt);
}
}

print $plistfh <<'EOD';
</array>
</dict>
</plist>
EOD
close($outfh);
close($plistfh);
