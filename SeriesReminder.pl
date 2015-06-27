#!/usr/bin/perl

use HTML::DOM;
use LWP::Simple;
use MIME::Lite;
use Proc::Daemon;

Proc::Daemon::Init;

while(1) {
	system('cp /home/pi/SeriesReminder/db.bak /home/pi/SeriesReminder/db.txt');
	open (DATEI, "/home/pi/SeriesReminder/db.txt") or die $!;
	my @daten = <DATEI>;
	close (DATEI);

	open (DATEI, ">/home/pi/SeriesReminder/db.txt");

	foreach my $x (@daten) {
		my @teile = split(/\;/,$x);
		my $url = @teile[0].",s".@teile[2]."e1";
		$c = `curl $url`;
		my $content = get($url);
		my $dom = new HTML::DOM;
		$dom -> write($c);
		my $as = $dom->getElementById('SeasonSelection')->length;
		my $ae = $dom->getElementById('EpisodeSelection')->length;
		my $msg = "";

		if ($as > @teile[2]) {
			$msg = "Neue Staffel bei ".@teile[1]." verfügbar. ".@teile[0].",s".@teile[2]."e1";
			print $msg;
			system('echo '.$msg.' | mail -s SeriesReminder dlkp212@gmail.com');
			print DATEI @teile[0].";".@teile[1].";".$as.";1\n";
		}
		elsif ($ae > @teile[3]) {
			$msg = "Neue Episode bei ".@teile[1]." verfügbar. ".@teile[0].",s".@teile[2]."e".$ae;
			print $msg;
			system('echo '.$msg.' | mail -s SeriesReminder dlkp212@gmail.com');
			print DATEI @teile[0].";".@teile[1].";".$as.";".$ae."\n";
		}
		else {
			print DATEI @teile[0].";".@teile[1].";".$as.";".$ae."\n";
		}
	}

	close (DATEI);
	system('cp /home/pi/SeriesReminder/db.txt /home/pi/SeriesReminder/db.bak');
	sleep(3600);
}
