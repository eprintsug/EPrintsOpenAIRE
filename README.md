# EPrintsOpenAIRE
Export to OpenAIRE (Guidelines for Literature Repositories v4) from EPrints digital repository software.

## Bazaar Plugin
http://bazaar.eprints.org/1224/

## Documentation

The metadata guidelines: 
* https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/
* https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/application_profile.html

The phrase file (https://github.com/photomedia/EPrintsOpenAIRE/blob/main/lib/lang/en/phrases/license_phrases.xml) contains phrases that would be required for the plugin if/when it includes the LicenseCondition field (https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/field_licensecondition.html#aire-licensecondition).  Current version of this plugin doesn't export this field; it is not Mandatory in V4 of the guidelines.  

## Configuration settings

### Enabling the OpenAIRE export plugins

You will have to add the following two lines to your local configuration to enable the plugins:

```
$c->{plugins}->{"Export::OPENAIRE"}->{params}->{disable} = 0;
$c->{plugins}{"Export::OPENAIRE_via_PMH"}{params}{disable} = 0;
```

One common place to add this is in a `plugins.pl` file here: `/archives/[REPOID]/cfg/cfg.d/`

### Locally defined item types

If your repository has additional item types that map to existing COAR resource types (not just 'other'), these can now 
be defined in your archive's configuration. If the resourceType URI doesn't exist in the Export::OPENAIRE plugin, this can
also be defined in your config.

Please see the examples in `cfg.d/z_openaire.pl` for full details.

### Additional data mapping

If your repository holds additional metadata that would map into the [OpenAIRE Literature v4 application profile](https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/application_profile.html), these can be defined in the config via a 
`$c->{"openaire"}->{"additional_export_elements"}` method.

Any addittion (or re-mapping) must conform to the application profile.
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
