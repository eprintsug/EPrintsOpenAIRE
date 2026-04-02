# EPrintsOpenAIRE - v1.1.0 (April 2026)
Export to OpenAIRE (Guidelines for Literature Repositories v4) from EPrints digital repository software.

## Bazaar Plugin
https://bazaar.eprints.org/id/epm/OpenAIRELit4
The source for the Bazaar package is currently in the main branch: https://github.com/eprintsug/EPrintsOpenAIRE/

## Eprints ingredient
https://github.com/eprintsug/EPrintsOpenAIRE/tree/3_4 - use the 3_4 branch.

## Metadata Schema Documentation

The metadata guidelines: 
* https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/
* https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/application_profile.html

### Metadata overview
The OpenAIRE metadata profile defines the following fields:

#### Mandatory fields
Title, Creator, Publication Date, Resource Type, Resource Identifier, Access Rights

#### Mandatory if applicable
Contributor, Funding Reference, Embargo Period Date, Language, Publisher, Description, Subject, File Location

#### Recommended
Alternate Identifier, Related Identifier, Format, Source, License Condition (see below), Coverage, Resource Version
Citation Title, Citation Volume, Citation Issue, Citation Start Page, Citation End Page, Citation Edition, Citation Conference Place, Citation Conference Date, 

_License Condition_: the text and URI for this are derived from the `license_description_[license_type]` phrase. The href of the first link,
and the text of the first link in the phrase willbe used for this element.
If you have a custom licences in your repository (e.g. 'term_access') the description phrase for them should be in the format:
```xml
<epp:phrase id="licenses_description_term_access">
    <a href="{$config{base_url}}/policies.html#TermsOfAccess">Repo Name - Terms of Access</a>
</epp:phrase>
```
If no license description phrase exists, or if it doesn't have a link in it, the LIcence Condition element will not be generated.


#### Optional (currently not mapped)
Size, Geo Location, Audience

_Whilst the above fields are not mapped, if your repository has this data you can now use the `additional_export_elements` (see below)
to add these elements to the record representation._ 


## Configuration settings

### Enabling the OpenAIRE export plugins

You will have to add the following two lines to your local configuration to enable the plugins:

```perl
$c->{plugins}->{"Export::OPENAIRE"}->{params}->{disable} = 0;
$c->{plugins}->{"Export::OPENAIRE_via_PMH"}->{params}->{disable} = 0;
```

One common place to add this is in a `plugins.pl` file here: `/archives/[REPOID]/cfg/cfg.d/`

### Excluding documents from the metadata
If documents meeting specific criteria should be excluded from the metadata harvested from your repository, a config function
can be defined to exclude them.

There is an example in `cfg.d/z_openaire.pl` that tests for a non-standard 'security' value, and will exclude the document if it is 'hidden'.
```perl
$c->{"openaire"}->{"exclude_document"} = sub
{
    my( $doc, $repo ) = @_;
    # your logic here
    # ...
    return 1; # to exclude the document
    return 0; # to include the document (default).
}
```

### Locally defined item types

If your repository has additional item types that map to existing COAR resource types (not just 'other'), these can now 
be defined in your archive's configuration. If the resourceType URI doesn't exist in the Export::OPENAIRE plugin, this can
also be defined in your config.

Please see the examples in `cfg.d/z_openaire.pl` for full details.

### Additional data mapping

If your repository holds additional metadata that would map into the [OpenAIRE Literature v4 application profile](https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/application_profile.html), these can be defined in the config via a 
`$c->{"openaire"}->{"additional_export_elements"}` method.

Any addition (or re-mapping) must conform to the application profile.
Please see the example in `cfg.d/z_openaire.pl` for full details.

### Optional OpenAIRE OAI-PMH Custom Set Definition

Optionally, a repository may wish to define a specific OAI "custom set" for OpenAIRE to harvest from.  For example, if you only want a portion of the item_types to be harvested, and/or you want to limit the harvesting to unembargoed items of certain types (article, conference_item, book_section, monograph, book), you would define a custom set using something like this:

```perl
$oai->{custom_sets} = [
	{ 	spec => "openaire", name => "OpenAIRE Set - OA article conference book monograph",
		filters=> [
			{meta_fields=>["full_text_status"], value=>"public"},
			{meta_fields =>[qw( type )], merge => "ANY", value => "article conference_item book_section monograph book" }
		]
	}	
];
```

Normally, there should be an `oai.pl` file here: `/archives/[REPOID]/cfg/cfg.d/`
This is where other oai-pmh configuration settings are, so this is where you would add this to create a custom set for OpenAIRE.


## Acknowledgements
This was developed by Tomasz Neugebauer and initially hosted at https://github.com/photomedia/EPrintsOpenAIRE
