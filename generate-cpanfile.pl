#!/usr/bin/env perl

use strict;
use warnings;
no warnings 'once';

exit if -e "/home/koha/koha/cpanfile";

require '/home/koha/koha/C4/Installer/PerlDependencies.pm';

my $prereqs = {};
while (my ($module, $req) = each %{ $C4::Installer::PerlDependencies::PERL_DEPS }) {
    my $type = $req->{required} ? 'requires' : 'recommends';

    $prereqs->{runtime}->{$type}->{$module} = $req->{min_ver};
}

my @recommends_that_should_be_requires = qw(
    Cache::Memcached::Fast
    Cache::Memcached::Fast::Safe
    GD
    Readonly
    Readonly::XS
);

foreach my $module (@recommends_that_should_be_requires) {
    if (exists $prereqs->{runtime}->{recommends}->{$module}) {
        $prereqs->{runtime}->{requires}->{$module} = delete $prereqs->{runtime}->{recommends}->{$module};
    }
}

$prereqs->{runtime}->{requires}->{'Catmandu::MARC'} = '1.241';
$prereqs->{runtime}->{requires}->{'Catmandu::Store::ElasticSearch'} = '>= 0.0507, <= 0.0512';
$prereqs->{runtime}->{requires}->{'CPAN::Meta'} = '2.150006';
$prereqs->{runtime}->{requires}->{'Module::CPANfile'} = '1.1000';

open my $fh, '>', '/home/koha/koha/cpanfile';
while (my ($type, $modules) = each %{ $prereqs->{runtime} }) {
    while (my ($module, $version) = each %$modules) {
        print $fh "$type '$module', '$version';\n";
    }
}
close $fh;
