######################################################################
#
# EPrints::Plugin::Export::OPENAIRE_via_PMH
#
######################################################################
#
#
######################################################################


=pod

=head1 NAME

B<EPrints::Plugin::Export::OPENAIRE_via_PMH> - Wrapper for OAI-PMH exportion of OPENAIRE objects.

=head1 DESCRIPTION

This plugin enables OPENAIRE maps to be discovered via the OAI2 PMH interface to EPrints.

=over 4

=cut
package EPrints::Plugin::Export::OPENAIRE_via_PMH;

use EPrints::Plugin::Export;

@ISA = ( "EPrints::Plugin::Export" );

use strict;

sub new
{
	my( $class, %opts ) = @_;

	my $self = $class->SUPER::new( %opts );

	$self->{name} = "OpenAIRE";
	$self->{accept} = [ 'dataobj/eprint' ];
	$self->{visible} = "";
	$self->{suffix} = ".xml";
	$self->{mimetype} = "application/xml";
	
	$self->{metadataPrefix} = "oai_openaire";
	$self->{xmlns} = "http://namespace.openaire.eu/schema/oaire/";
	$self->{schemaLocation} = "https://www.openaire.eu/schema/repo-lit/4.0/openaire.xsd";

	return $self;
}


sub output_dataobj
{
	my( $plugin, $dataobj ) = @_;

	my $xml = $plugin->xml_dataobj( $dataobj );

	my $resourceMap = EPrints::XML::to_string( $xml );

	EPrints::XML::dispose($xml);

	return $resourceMap;
}


sub xml_dataobj
{
	my( $plugin, $dataobj ) = @_;

	my $main_plugin = $plugin->{session}->plugin( "Export::OPENAIRE" );

	my $data = $main_plugin->xml_dataobj( $dataobj );
	
	return $data;
}


1;

=head1 COPYRIGHT

=for COPYRIGHT BEGIN

Copyright 2000-2011 University of Southampton.
Copyright 2019 Tomasz Neugebauer, Concordia University

=for COPYRIGHT END

=for LICENSE BEGIN

This file is part of EPrints L<http://www.eprints.org/>.

EPrints is free software: you can redistribute it and/or modify it
under the terms of the GNU Lesser General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

EPrints is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
License for more details.

You should have received a copy of the GNU Lesser General Public
License along with EPrints.  If not, see L<http://www.gnu.org/licenses/>.

=for LICENSE END

