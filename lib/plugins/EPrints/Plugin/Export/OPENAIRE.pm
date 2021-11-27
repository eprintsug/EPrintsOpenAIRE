######################################################################
#
# EPrints::Plugin::Export::OPENAIRE
#
######################################################################
#
#
######################################################################


=pod

=head1 NAME

B<EPrints::Plugin::Export::OPENAIRE> - OPENAIRE Export plugin.

=head1 DESCRIPTION

This export plugin is written to export in compliance with Guidelines for Literature Repositories OPENAIRE v4

=over 4

=cut

package EPrints::Plugin::Export::OPENAIRE;

use EPrints::Plugin::Export::OPENAIRE;
@ISA = ( "EPrints::Plugin::Export::XMLFile" );

use strict;

sub new
{
	my( $class, %opts ) = @_;
	my $self = $class->SUPER::new( %opts );

	$self->{name} = "OPENAIRE";
	#$self->{accept} = [ 'dataobj/eprint', 'list/eprint' ]; 
	$self->{accept} = [ 'dataobj/eprint'];  #only output one eprint
	$self->{visible} = 'all';
    $self->{suffix} = '.xml';
    $self->{mimetype} = 'application/xml; charset=utf-8';
	

	return $self;
}


sub output_list
{
	my( $plugin, %opts ) = @_;

	my $type = $opts{list}->get_dataset->confid;
	
	my $part = "";
	
	my $r = [];

	if( defined $opts{fh} )
	{
		print {$opts{fh}} $plugin->xml_header();
	}
	else
	{
		push @{$r}, $plugin->xml_header();
	}

	$opts{list}->map(sub {
		my( $session, $dataset, $dataobj ) = @_;
		$part = $plugin->output_dataobj( $dataobj, multiple => 1, %opts );
		if( defined $opts{fh} )
		{
			print {$opts{fh}} $part;
		}
		else
		{
			push @{$r}, $part;
		}
	});

	if( defined $opts{fh} )
	{
		print {$opts{fh}} $plugin->xml_footer();
	}
	else
	{
		push @{$r}, $plugin->xml_footer();
	}


	if( defined $opts{fh} )
	{
		return;
	}

	return join( '', @{$r} );
}


sub output_dataobj
{
	my( $plugin, $dataobj, %opts ) = @_;

	my $multiple = $opts{"multiple"};
	
	my $response = $plugin->xml_dataobj ($dataobj);

	my $resourceMap= EPrints::XML::to_string( $response );
	EPrints::XML::dispose( $response );
	
    return "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>".$response;

}



sub xml_dataobj
{
	my( $plugin, $dataobj, %opts ) = @_;

	my $multiple = $opts{"multiple"};
	
	my $title;
	if( $dataobj->dataset->get_field("title"))
	{
		$title = $dataobj->get_value( "title" );	
	}
	else
	{
		$title = "EPrint #".$dataobj->get_value( "eprintid" );	
	}
	my $eprint_url = $dataobj->get_url;
	my $session = $plugin->{session};
	
	my $eprint_type = $dataobj->get_value( "type" );
		
	my $response = $plugin->{session}->make_element(
        	"oaire:resource",
		"xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
        	"xmlns:rdf" => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
        	"xmlns:dc" => "http://www.w3.org/2001/XMLSchema-instance",
			"xmlns:datacite" => "http://datacite.org/schema/kernel-4",
			"xmlns:vc" => "http://www.w3.org/2007/XMLSchema-versioning",
			"xmlns:oaire" => "http://namespace.openaire.eu/schema/oaire/",
		"xsi:schemaLocation" =>"http://namespace.openaire.eu/schema/oaire/ https://www.openaire.eu/schema/repo-lit/4.0/openaire.xsd" );

    #TITLE
	my $topcontent = $session->make_element( "datacite:titles");
	my $sub_content = "";
	$sub_content = $session->render_data_element (
		4,
		"datacite:title",
		$title );
	$topcontent->appendChild( $sub_content);
	$response->appendChild( $topcontent );	

    #CREATORS
    $topcontent = $session->make_element( "datacite:creators");
    $sub_content = "";
    my $names = $dataobj->get_value( "creators" );
    foreach my $name ( @$names )
      { 
        my $name_str = EPrints::Utils::make_name_string( $name->{name});
	        $sub_content = $session->render_data_element (
	    	4,
		    "datacite:creatorName",
		    $name_str );
	    $topcontent->appendChild( $sub_content);
      }
	$response->appendChild( $topcontent );	
	
	#FUNDERS
	if ($dataobj->exists_and_set("funders")){
		$topcontent = $session->make_element( "oaire:fundingReferences");
		$sub_content = "";
		my $names = $dataobj->get_value( "funders" );
		foreach my $name ( @$names )
		  { 
		    $sub_content = $session->make_element( "oaire:fundingReference");
			my $name_str = $name;
			my $sub_sub_content = $session->render_data_element (
				4,
				"oaire:funderName",
				$name_str );
			$sub_content->appendChild( $sub_sub_content);
			$topcontent->appendChild( $sub_content);
		  }
		$response->appendChild( $topcontent );	
	}
	
	# Map Eprints type to oaire:resourceType label
	#article, book_section, monograph, conference_item, book, thesis, graduate_projects, patent, artefact, exhibition, composition, performance, image, video, audio, dataset, experiment, teaching_resource, other
	 my %type_map = (
	 "article" => "journal article",
	 "book_section" => "book part",
	 "monograph" => "monograph",	#this has subtypes, so we deal with it below
	 "conference_item" => "conference object", #this has subtypes, so we deal with it below
	 "book" => "book",
	 "thesis" => "thesis", #this has subtypes, so we deal with it below
	 "graduate_projects" => "other",
	 "patent" => "patent",
	 "artefact" => "other",
	 "exhibition" => "other",
	 "composition" => "musical composition",
	 "performance" => "other",
	 "image" => "image",
	 "video" => "video",
	 "audio" => "sound",
	 "dataset" => "dataset",
	 "experiment" => "other",
	 "teaching_resource" => "other",
	 "other" => "other"
	);
	
	# map type URI from OPENAIRE https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/field_publicationtype.html
	 my %type_map_uri = (
	 	"annotation" => "http://purl.org/coar/resource_type/c_1162",
	 	"journal article" => "http://purl.org/coar/resource_type/c_6501",
 	 	"letter to the editor" => "http://purl.org/coar/resource_type/c_545b",
 	 	"editorial" => "http://purl.org/coar/resource_type/c_b239",
 		"research article" => "http://purl.org/coar/resource_type/c_2df8fbb1",
 		"review article" => "http://purl.org/coar/resource_type/c_dcae04bc",
		"data paper" => "http://purl.org/coar/resource_type/c_beb9" ,
		"contribution to journal" => "http://purl.org/coar/resource_type/c_3e5a" ,
		"book review" => "http://purl.org/coar/resource_type/c_ba08" ,
 		"book part" => "http://purl.org/coar/resource_type/c_3248",
		"book" => "http://purl.org/coar/resource_type/c_2f33",
		"bibliography" => "http://purl.org/coar/resource_type/c_86bc"	,
		"preprint" => "http://purl.org/coar/resource_type/c_816b",
		"working paper" => "http://purl.org/coar/resource_type/c_8042",
		"technical documentation" => "http://purl.org/coar/resource_type/c_71bd",
		"technical report" => "http://purl.org/coar/resource_type/c_18gh",
		"research report" => "http://purl.org/coar/resource_type/c_18ws",
		"report to funding agency" => "http://purl.org/coar/resource_type/c_18hj"	,
		"project deliverable" => "http://purl.org/coar/resource_type/c_18op",
		"policy report" => "http://purl.org/coar/resource_type/c_186u",
		"other type of report" => "http://purl.org/coar/resource_type/c_18wq",
		"memorandum" => "http://purl.org/coar/resource_type/c_18wz"	,
		"internal report" => "http://purl.org/coar/resource_type/c_18ww",
		"review" => "http://purl.org/coar/resource_type/c_efa0"	,
		"research proposal" => "http://purl.org/coar/resource_type/c_baaf",
		"report part" => "http://purl.org/coar/resource_type/c_ba1f",
		"report" => "http://purl.org/coar/resource_type/c_93fc",
		"patent" => "http://purl.org/coar/resource_type/c_15cd",
		"conference poster not in proceedings" => "http://purl.org/coar/resource_type/c_18co",
		"conference paper not in proceedings" => "http://purl.org/coar/resource_type/c_18cp",
		"conference poster" => "http://purl.org/coar/resource_type/c_6670",
		"conference paper" => "http://purl.org/coar/resource_type/c_5794",
		"conference object" => "http://purl.org/coar/resource_type/c_c94f"	,
		"conference proceedings" => "http://purl.org/coar/resource_type/c_f744",
		"bachelor thesis" => "http://purl.org/coar/resource_type/c_7a1f",
		"master thesis" => "http://purl.org/coar/resource_type/c_bdcc",
		"doctoral thesis" => "http://purl.org/coar/resource_type/c_db06",
		"thesis" => "http://purl.org/coar/resource_type/c_46ec"	,
		"letter" => "http://purl.org/coar/resource_type/c_0857",
		"lecture" => "http://purl.org/coar/resource_type/c_8544"	,
		"text" => "http://purl.org/coar/resource_type/c_18cf"	,
		"musical notation" => "http://purl.org/coar/resource_type/c_18cw"	,
		"musical composition" => "http://purl.org/coar/resource_type/c_18cd",
		"sound" => "http://purl.org/coar/resource_type/c_18cc",
		"video" => "http://purl.org/coar/resource_type/c_12ce",
		"moving image" => "http://purl.org/coar/resource_type/c_8a7e"	,
		"still image" => "http://purl.org/coar/resource_type/c_ecc8"	,
		"image" => "http://purl.org/coar/resource_type/c_c513"	,	
		"map" => "http://purl.org/coar/resource_type/c_12cd"	,
		"cartographic material" => "http://purl.org/coar/resource_type/c_12cc",
		"software" => "http://purl.org/coar/resource_type/c_5ce6",
		"dataset" => "http://purl.org/coar/resource_type/c_ddb1",
		"interactive resource" => "http://purl.org/coar/resource_type/c_e9a0",
		"website" => "http://purl.org/coar/resource_type/c_7ad9"	,
		"workflow" => "http://purl.org/coar/resource_type/c_393c",
		"other" => "http://purl.org/coar/resource_type/c_1843"
	 );
	 

	my $mapped_type = (exists $type_map{$eprint_type}) ? $type_map{$eprint_type} : "other";
	
	#deal with document subtypes
	if ($mapped_type eq "monograph"){
		$mapped_type =  "other"; #default is other
		if ($dataobj->exists_and_set( "monograph_type" )) {
				if ($dataobj->get_value("monograph_type") eq "working_paper") {
					$mapped_type = "working paper";
				}
				if ($dataobj->get_value("monograph_type") eq "technical_report"){
					$mapped_type = "technical report";
				}
		}
	}
	
	#map from labels to URIs
	my $mapped_type_URI = (exists $type_map_uri{$mapped_type}) ? $type_map_uri{$mapped_type} : "http://purl.org/coar/resource_type/c_1843";
	
	#map resourceTypeGeneral based on OpenAIRE
	my $mapped_resourceTypeGeneral = "literature";
	if ($mapped_type eq "dataset"){
		$mapped_resourceTypeGeneral = "dataset";
	}
	
	# <oaire:resourceType resourceTypeGeneral="literature" uri="http://purl.org/coar/resource_type/c_93fc">report</oaire:resourceType>
	#resourceType
	$topcontent = $session->make_element( "oaire:resourceType",
				"uri"=>"$mapped_type_URI", "resourceTypeGeneral"=> "$mapped_resourceTypeGeneral" );
	$topcontent->appendChild($session->make_text($mapped_type));
	
	$response->appendChild( $topcontent );	
	
	#<datacite:identifier identifierType="Handle">http://hdl.handle.net/1234/5628</datacite:identifier>
	$topcontent = $session->make_element( "datacite:identifier",
				"identifierType"=>"URI");
	$topcontent->appendChild($session->make_text($eprint_url));
	
	$response->appendChild( $topcontent );	

	my $mapped_rights_URI="";
	
	#Add rights info 
	my $repo = $plugin->{session}->get_repository;
	
	my $rightsLabel = "metadata only access"; #default, unless we find a document
	my $filerightsLabel = "open access"; #default file-level rights label is open access
	
	my $embargo_expiry_date = ""; #default NULL embargo date
	
	# map type URI from OPENAIRE https://openaire-guidelines-for-literature-repository-managers.readthedocs.io/en/v4.0.0/field_accessrights.html
	my %type_map_rightsuri = (
	"open access" => "http://purl.org/coar/access_right/c_abf2",
	"embargoed access" => "http://purl.org/coar/access_right/c_f1cf",
	"restricted access" => "http://purl.org/coar/access_right/c_16ec",
	"metadata only access" => "http://purl.org/coar/access_right/c_14cb",
	);
	
	#check if at least one document, so default to open access unless we find an embargo or restriction
	my @docs = $dataobj->get_all_documents();
	if (@docs > 0) {
		$rightsLabel = "open access";
	}
	
	#go through documents, determine "rightsLabel" to be open access, embargoed, restricted or metadata only
	foreach my $doc ( @docs ) {
		if($doc->exists_and_set("date_embargo")){
				$filerightsLabel = "embargoed access"; #this document is embargoed
				$rightsLabel = "embargoed access"; #at least one embargoed - so eprint embargoed
				$embargo_expiry_date = $doc->value("date_embargo"); #store embargo expiry date
        }
		elsif($doc->exists_and_set("security")){
			if (($doc->value("security") eq "staffonly") || ($doc->value("security") eq "validuser")){
				$filerightsLabel = "restricted access"; #this document is restricted
				$rightsLabel = "restricted access"; # at least one restricted - so eprint restricted
			}
			elsif ($doc->value("security") eq "public") {
				#this document is open access (no embargo date or user restrictions)
				$filerightsLabel = "open access"; #this document is open access
			}	
		}
		#<oaire:file accessRightsURI="http://purl.org/coar/access_right/c_abf2" mimeType="application/pdf" objectType="fulltext">http://link-to-the-fulltext.org</oaire:file>
		$mapped_rights_URI = (exists $type_map_rightsuri{$filerightsLabel}) ? $type_map_rightsuri{$filerightsLabel} : "";
		my $mime_type=$doc->value("mime_type");
		my $docurl=$doc->get_url;
		$topcontent = $session->make_element( "oaire:file","rightsURI"=>"$mapped_rights_URI","mimeType"=>"$mime_type");
		$topcontent->appendChild($session->make_text("$docurl"));
		$response->appendChild( $topcontent );	
	}

	
	
	#map eprint rights from label to URIs
	$mapped_rights_URI = (exists $type_map_rightsuri{$rightsLabel}) ? $type_map_rightsuri{$rightsLabel} : "";
	
	#<datacite:rights rightsURI="http://purl.org/coar/access_right/c_abf2">open access</datacite:rights>
	$topcontent = $session->make_element( "datacite:rights",
				"rightsURI"=>"$mapped_rights_URI");
	$topcontent->appendChild($session->make_text($rightsLabel));
	
	$response->appendChild( $topcontent );	
	
	#<datacite:date dateType="Issued">2000-12-25</datacite:date>
	my $date = "";
	my $dateType = "";
	
	if( $dataobj->exists_and_set("date")){
		$date = $dataobj->get_value( "date" );	
	}
	if( $dataobj->exists_and_set("date_type")){
		$dateType = $dataobj->get_value( "date_type" );	
	}
	
	#for everything except for theses, the mapping is like this:
	my %type_map_date = (
	 "submitted" => "Available",
	 "published" => "Issued",
 	 "completed" => "Available",
	 );
	 
	 #for theses, we should always have completion date which maps to Accepted date, if another date type is stored, treat it the same way as other document types above
	 my %type_map_date_theses = (
	 "submitted" => "Available",
	 "published" => "Issued",
 	 "completed" => "Accepted",
	 ); 
	 
	my $mapped_dateType="";
	
	if ($mapped_type eq "thesis"){
		#map from eprints to openaire date types (theses)
		$mapped_dateType = (exists $type_map_date_theses{$dateType}) ? $type_map_date_theses{$dateType} : "";
		}
	else{
		#map from eprints to openaire date types (non theses)
		$mapped_dateType = (exists $type_map_date{$dateType}) ? $type_map_date{$dateType} : "";
	}
	
	#if embargoed, always set the date available to embargo expiry date
	if ($embargo_expiry_date ne ""){
		#in some cases more than one date may be needed, specifically: when we have published date or accepted date (theses) and embargo expiry date
		if ($mapped_dateType eq "Issued"){
			$topcontent = $session->make_element( "datacite:dates");
			$sub_content = $session->make_element( "datacite:date",
					"dateType"=>"Available");
			$sub_content->appendChild($session->make_text($embargo_expiry_date));
			$topcontent->appendChild($sub_content);
			$sub_content = $session->make_element( "datacite:date",
					"dateType"=>"Issued");
			$sub_content->appendChild($session->make_text($date));
			$topcontent->appendChild($sub_content);
			$response->appendChild( $topcontent );	
		}
		elsif (($mapped_dateType eq "Accepted") && ($mapped_type eq "thesis")){
			$topcontent = $session->make_element( "datacite:dates");
			$sub_content = $session->make_element( "datacite:date",
					"dateType"=>"Available");
			$sub_content->appendChild($session->make_text($embargo_expiry_date));
			$topcontent->appendChild($sub_content);
			$sub_content = $session->make_element( "datacite:date",
					"dateType"=>"Accepted");
			$sub_content->appendChild($session->make_text($date));
			$topcontent->appendChild($sub_content);
			$response->appendChild( $topcontent );	
		}
		else{
			#when we have embargo expiry date and either submitted or completed date, only provide the embargo expiry date
			$topcontent = $session->make_element( "datacite:date",
				"dateType"=>"Available");
			$topcontent->appendChild($session->make_text($embargo_expiry_date));
			$response->appendChild( $topcontent );	
		}
	}

	#no embargo, so OA dates apply
	elsif ($date ne ""){
		$topcontent = $session->make_element( "datacite:date",
				"dateType"=>"$mapped_dateType");
				
		$topcontent->appendChild($session->make_text($date));
	
		$response->appendChild( $topcontent );	

	}
	
	#extract individual subject keywords from the combined field
	if( $dataobj->exists_and_set("keywords")){
		$topcontent = $session->make_element( "datacite:subjects");

		my $subjects = $dataobj->get_value( "keywords" );
		my $subcontent = "";
		my $subject = "";

		my @words = split /[;\,]/, $subjects;

		foreach ( @words ) {
			$subcontent = $session->make_element( "datacite:subject");
			$subject = $session->make_text($_);
			$subcontent->appendChild($subject);
			$topcontent->appendChild($subcontent);
		}

		$response->appendChild( $topcontent );	
	}
	
	EPrints::XML::tidy( $response );
	return $response;

}

1;

=head1 COPYRIGHT

=for COPYRIGHT BEGIN

Copyright 2021 Tomasz Neugebauer, Concordia University


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
