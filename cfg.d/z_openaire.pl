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
#
#
