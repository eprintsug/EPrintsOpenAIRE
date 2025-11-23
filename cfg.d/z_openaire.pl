$c->{plugins}->{"Export::OPENAIRE"}->{params}->{disable} = 0;
$c->{plugins}{"Export::OPENAIRE_via_PMH"}{params}{disable} = 0;

# If you have additional item types configured in your repository, add an entry for them here.
# The key should be the eprint type, and the value should be something defined here:
# https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/latest/field_publicationtype.html
#
# Values defined here will be added to the default mappings in the Export::OPENAIRE plugin.
# If a key is present in both, the value mapped here will 'win'.
#$c->{"openaire"}->{"type_map_local"} = {
#	"map"			=> "cartographic material",
#	"eprints_manual"	=> "technical documentation",
#};

# If the mapped value abvoe does not exist in the default URI map in the Export::OPENAIRE plugin,
# also make an entry here to get the URI for the value above.

#$c->{"openaire"}->{"type_map_uri_local"} = {
#	"cartographic material"		=> "http://purl.org/coar/resource_type/c_12cc",
#	"technical documentation"       => "http://purl.org/coar/resource_type/c_71bd",
#};


# The following can be used to map additional elements into the Export::OPENAIRE output.
# This can be useful if you have custom field config for storing e.g. funders.
# $response is an EPrints::XML object (probably an XML::LibXML object too)
# and will already contain all elements the standard export can deal with.
#
# Elements added here MUST conform to the relevant schema:
# https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/application_profile.html
#
# Existing elements in the response can be updated - see the 'software' section below

#$c->{"openaire"}->{"additional_export_elements"} = sub
#{
#	my( $response, $eprint, $repo ) = @_;
#
#	# Making something like: <oaire:citationTitle>some Journal Title</oaire:citationTitle>
#	if( $eprint->exists_and_set( "publication" ) )
#	{
#		my $cit_title = $repo->make_element( "oaire:citationTitle" );
#		$cit_title->appendChild( $repo->make_text( $eprint->value( "publication" ) ) );
#
#		$response->appendChild( $cit_title );
#	}
#
#	# Example showing update of existing element in $response
#	if( $eprint->get_type eq "software" )
#	{
#		foreach( $response->getElementsByLocalName( "oaire:resourceType" ) )
#		{
#			if( $_->hasAttribute( "resourceTypeGeneral" ) )
#			{
#				$_->setAttribute( "resourceTypeGeneral", "software" );
#			}
#		};
#	}
#	# no return necessary - we're adding to $response directly
#};
