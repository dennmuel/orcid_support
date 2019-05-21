package EPrints::Plugin::Screen::Report::User::Orcid::AllUsersOrcid;

use EPrints::Plugin::Screen::Report::User::Orcid;
our @ISA = ( 'EPrints::Plugin::Screen::Report::User::Orcid' );

use strict;

sub new
{
        my( $class, %params ) = @_;

        my $self = $class->SUPER::new( %params );

        $self->{report} = 'orcid-all-users';

        return $self;
}

sub ajax_user
{
        my( $self ) = @_;

        my $repo = $self->repository;

        my $json = { data => [] };

        $repo->dataset( "user" )
        ->list( [$repo->param( "user" )] )
        ->map(sub {
                (undef, undef, my $user) = @_;

                return if !defined $user; # odd

                my $frag = $user->render_citation_link;
                push @{$json->{data}}, {
                        datasetid => $user->dataset->base_id,
                        dataobjid => $user->id,
                        summary => EPrints::XML::to_string( $frag ),
#                       grouping => sprintf( "%s", $user->value( SOME_FIELD ) ),
                        problems => [ $self->validate_dataobj( $user ) ],
			bullets => [ $self->bullet_points( $user ) ],
                };
        });
        print $self->to_json( $json );
}

sub validate_dataobj
{

        my( $self, $user ) = @_;

        my $repo = $self->{repository};

        my @problems;

        #is there an ORCID?
        if( !$user->is_set( "orcid" ) )
        {
                push @problems, $repo->phrase( "orcid_missing" );
        }
        return @problems;
}

sub bullet_points
{
        my( $self, $user ) = @_;

        my $repo = $self->{repository};

        my @bullets;

	if( $user->is_set( "orcid" ) )
	{
 		push @bullets, EPrints::XML::to_string( $repo->html_phrase( "user_with_orcid", orcid => $repo->xml->create_text_node( $user->get_value( "orcid" ) ) ) );
	}

        return @bullets;
}
