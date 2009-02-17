# -*- perl -*-
#
# Test::AutoBuild::Stage::Yum
#
# Daniel Berrange <dan@berrange.com>
# Dennis Gregorovic <dgregorovic@alum.mit.edu>
#
# Copyright (C) 2004 Red Hat, Inc.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
# $Id: Yum.pm,v 1.9 2007/12/08 17:35:16 danpb Exp $

=pod

=head1 NAME

Test::AutoBuild::Stage::Yum - Create an index for Yum package management tool

=head1 SYNOPSIS

  use Test::AutoBuild::Stage::Yum

  my $stage = Test::AutoBuild::Stage::Yum->new(name => "yum",
					       label => "Create yum index",
					       options => {
						 directory => "/var/lib/builder/public_html/dist",
						 parameters => "-d -s -n",
					       });

  $stage->run($runtime);

=head1 DESCRIPTION

This module invokes the C<yum-arch(8)> command to generate an index of RPM
packages generated during the build. The index enables use of the C<yum(8)>
command to install packages generated by the builder. The C<yum-arch(8)>
command is expected to be found in the C<$PATH>.

=head1 CONFIGURATION

In addition to the standard parameters defined by the L<Test::AutoBuild::Stage>
module, this module accepts two entries in the C<options> parameter:

=over 4

=item directory

The full path to the directory containing RPMs to be indexed. If this option
is not specified, then the C<directories> option must be set.

=item directories

An array of paths to directories containing RPMs to be indexed. If this option
is not specified, then the C<directory> option must be set.

=item parameters

A string of command line arguments to be passed to the C<yum-arch> command,
see the C<yum-arch(8)> manual page for details of possible values.

=back

=head2 EXAMPLE

  {
    name = yum
    label = Update Yum Repository
    module = Test::AutoBuild::Stage::Yum
    critical = 0
    options = {
      directory = /var/lib/builder/public_html/dist
      parameters = -d
    }
  }


=head1 METHODS

=over 4

=cut

package Test::AutoBuild::Stage::Yum;

use base qw(Test::AutoBuild::Stage);
use warnings;
use strict;
use Log::Log4perl;

=item $stage->process($runtime);

For each directory defined in the C<options> parameter, this method will
run the C<yum-arch> command to generate the index.

=cut

sub process {
    my $self = shift;
    my $runtime = shift;

    my $log = Log::Log4perl->get_logger();
    my $directories = $self->option('directories');
    if (!defined $directories) {
	my $dir = $self->option("directory");
	$directories = [$dir];
    }
    if (defined $directories) {
	foreach my $directory (@{$directories}) {
	    my $dirs = Test::AutoBuild::Lib::_expand_standard_macros([[ "", $directory, {} ]], $runtime);
	    foreach my $expanded_dir (@{$dirs}) {
		if (-d $expanded_dir->[1]) {
		    my $parameters = $self->option('parameters') ||  "";
		    my $cmdopt = $self->option("command") || {};
		    my $mod = $cmdopt->{module} || "Test::AutoBuild::Command::Local";
		    my $opts = $cmdopt->{options} || {};
		    eval "use $mod;";
		    die "cannot load $mod: $!" if $@;

		    my @cmd = ("yum-arch",
			       ref($parameters)? @{$parameters} : ($parameters),
			       $expanded_dir->[1]);
		    my $c = $mod->new(cmd => \@cmd,
				      dir => $expanded_dir->[1],
				      options => $opts);

		    my ($output, $errors);
		    my $status = $c->run(\$output, \$errors);

		    $output = "" unless defined $output;
		    $errors = "" unless defined $errors;
		    my $log = Log::Log4perl->get_logger();
		    $log->debug("Output: [$output]") if $output;
		    $log->debug("Errors: [$errors]") if $errors;

		    die "command '" . join("' '", @cmd) . "' exited with status $status\n$errors" if $status;
		} else {
		    $log->warn("directory does not exists: " . $expanded_dir->[1]);
		}
	    }
	}
    }
}

1 # So that the require or use succeeds.

__END__

=back

=head1 AUTHORS

Daniel Berrange <dan@berrange.com>
Dennis Gregorovic <dgregorovic@alum.mit.edu>

=head1 COPYRIGHT

Copyright (C) 2004 Red Hat, Inc.

=head1 SEE ALSO

C<perl(1)>, L<Test::AutoBuild::Stage>, C<yum(8)>, C<yum-arch(8)>

=cut