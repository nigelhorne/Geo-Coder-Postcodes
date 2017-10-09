#!perl -w

use warnings;
use strict;
use Test::Most tests => 8;

BEGIN {
	use_ok('Geo::Coder::Postcodes');
}

UK: {
	SKIP: {
		skip 'Test requires Internet access', 7 unless(-e 't/online.enabled');

		require Test::LWP::UserAgent;
		Test::LWP::UserAgent->import();

		require Test::Carp;
		Test::Carp->import();;

		eval {
			require Test::Number::Delta;

			Test::Number::Delta->import();
		};

		if($@) {
			diag('Test::Number::Delta not installed - skipping tests');
			skip 'Test::Number::Delta not installed', 7;
		}

		my $geocoder = new_ok('Geo::Coder::Postcodes');

		my $location = $geocoder->geocode('Ramsgate');
		delta_within($location->{latitude}, 51.33, 1e-2);
		delta_within($location->{longitude}, 1.42, 1e-2);

		$location = $geocoder->geocode('Ramsgate, Kent, England');
		delta_within($location->{latitude}, 51.33, 1e-2);
		delta_within($location->{longitude}, 1.42, 1e-2);

		my $ua = new_ok('Test::LWP::UserAgent');
		$ua->map_response('postcodes.io', new_ok('HTTP::Response' => [ '500' ]));

		$geocoder->ua($ua);
		eval {
			does_carp_that_matches(sub { 
				$location = $geocoder->geocode('Sheffield');
			}, qr/^postcodes.io API returned error: 500/);
		};
	}
}
