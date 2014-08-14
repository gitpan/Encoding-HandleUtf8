package Encoding::HandleUtf8;
# ABSTRACT: Fix the encoding for Perl value store (input) and general output (output) to a console or the web.
#
# This file is part of Encoding-HandleUtf8
#
# This software is Copyright (c) 2014 by BURNERSK <burnersk@cpan.org>.
#
# This is free software, licensed under:
#
#   The MIT (X11) License
#
use strict;
use warnings FATAL => 'all';

BEGIN {
  our $VERSION = '0.001'; # VERSION: generated by Dist::Zilla
}

use Carp qw( carp croak );
use Encoding::FixLatin qw( fix_latin );
use Clone 'clone';

############################################################################
# Prototype definition - required for the recursion, otherwise it will not
# find itself because it is not already in the internal symbol list.

sub fix_encoding ($\[$@%];$);
sub fix_encoding_return ($$;$);

############################################################################
# Setup exporter.

our @EXPORT_OK;

BEGIN {
  use base 'Exporter';
  @EXPORT_OK = qw( &fix_encoding &fix_encoding_return );
}

############################################################################
# Utility function to fix the encoding for Perl value store (input) and
# general output (output) to a console or the web.
# Second parameter is the object indended which should be fixed. Due to
# prototypes it automatically turns into an reference.
sub fix_encoding ($\[$@%];$) {
  my ( $direction, $obj, $skip_latin ) = @_;

  my $ref     = ref $obj;
  my $obj_ref = ref ${$obj};

  # Check encoding direction.
  croak sprintf q{invalid direction '%s' (input or output)}, $direction
    if !$direction || ( $direction ne 'input' && $direction ne 'output' );

  # If $obj is just a string everything is very basic.
  if ( $ref eq 'SCALAR' ) {

    # Fix possible mixed encodings.
    ${$obj} = fix_latin ${$obj} unless $skip_latin;

    # Final encoding it to UTF-8 (output) or Unicode (input).
    if ( $direction eq 'output' ) {
      utf8::encode ${$obj} if defined ${$obj} && utf8::is_utf8 ${$obj};
    }
    else {
      utf8::decode ${$obj} if defined ${$obj} && !utf8::is_utf8 ${$obj};
    }
  }

  # Otherwise if $obj is a reference we have to use some recursive magic.
  elsif ( $ref eq 'REF' ) {

    # Iterate over an array reference.
    if ( $obj_ref eq 'ARRAY' ) {
      fix_encoding $direction, $_ for ( @{ ${$obj} } );
    }

    # Iterate over the keys of a hash reference.
    elsif ( $obj_ref eq 'HASH' ) {
      fix_encoding $direction, ${$obj}->{$_} for ( keys %{ ${$obj} } );
    }

    # Everything else is not supported.
    else {
      carp sprintf q{unsupported reference '%s'}, $obj_ref;
    }

  }

  # w00t - this shouldn't ever happen!
  else {
    carp sprintf q{unknown object reference '%s'}, $ref;
  }

  return ${$obj};
}


############################################################################
# Does the same like fix_encoding but do not touches original reference.
sub fix_encoding_return ($$;$) {
  my ( $direction, $obj, $skip_latin ) = @_;
  my $obj_cloned = clone $obj;
  fix_encoding $direction, $obj_cloned, $skip_latin // 0;
  return $obj_cloned;
}



############################################################################
1;
############################################################################

__END__

=pod

=encoding UTF-8

=head1 NAME

Encoding::HandleUtf8 - Fix the encoding for Perl value store (input) and general output (output) to a console or the web.

=head1 VERSION

version 0.001

=head1 SYNOPSIS

    use Encoding::HandleUtf8 qw( fix_encoding fix_encoding_return );
    
    ########################################################################
    # Simple usage - CAUTION: clones the object.
    
    printf "%s\n", fix_encoding_return 'input', 'Here are some German umlauts: äÄüÜöÖßẞ';
    
    ########################################################################
    # Working with strings.
    
    my $string = 'Here are some German umlauts: äÄüÜöÖßẞ';
    
    # Fix the encoding of a input string to handle them safe within Perl.
    fix_encoding 'input', $string;
    
    # Fix the encoding of a Perl variable for output.
    fix_encoding 'output', $string;
    print "$string\n";
    
    ########################################################################
    # Working with hashes.
    
    my %hash = ( a => 'äÄ', u => 'üÜ', o => 'öÖ', ss => 'ßẞ' );
    
    # Fix the encoding of a hash to handle them safe within Perl.
    fix_encoding 'input', %hash;
    
    # Fix the encoding of a Perl hash for output.
    fix_encoding 'output', %hash;
    print "$_: $hash{$_}\n" for( keys %hash );
    
    ########################################################################
    # Working with hash references.
    
    my $hash = { a => 'äÄ', u => 'üÜ', o => 'öÖ', ss => 'ßẞ' };
    
    # Fix the encoding of a hash reference to handle them safe within Perl.
    fix_encoding 'input', $hash;
    
    # Fix the encoding of a Perl hash reference for output.
    fix_encoding 'output', %hash;
    print "$_: $hash->{$_}\n" for( keys %{ $hash } );
    
    ########################################################################
    # Working with arrays.
    
    my @array = ( 'äÄ', 'üÜ', 'öÖ', 'ßẞ' );
    
    # Fix the encoding of an array to handle them safe within Perl.
    fix_encoding 'input', @array;
    
    # Fix the encoding of a Perl array for output.
    fix_encoding 'output', @array;
    print "$_: $hash{$_}\n" for( @array );
    
    ########################################################################
    # Working with array references.
    
    my $array = [ 'äÄ', 'üÜ', 'öÖ', 'ßẞ' ];
    
    # Fix the encoding of an array reference to handle them safe within Perl.
    fix_encoding 'input', $array;
    
    # Fix the encoding of a Perl array reference for output.
    fix_encoding 'output', @array;
    print "$_: $hash{$_}\n" for( @{ $array } );

=head1 DESCRIPTION

Fix the encoding for Perl value store (input) and general output (output) to
e.g. a console or the web.

=head1 METHODS

=head2 fix_encoding

Takes an direction and a object and fixes the encoding.

=over

=item B<Required parameters>

=over

=item [0] C<$direction>

The direction in which the object should be fixed. Either C<input> to work
safely with inputs (convert to Unicode) or C<output> to output (convert to
UTF-8) them to e.g. a console or the web.

=item [1] C<$obj>

The actual object which should be fixed. Can either be a C<SCALAR>, C<HASH>
or C<ARRAY> (including but not mandentory: references).

=back

=item B<Optional parameters>

=over

=item [2] C<$skip_latin>

Skips L<Encoding::FixLatin>'s L<fix_latin|Encoding::FixLatin/fix_latin>
call on scalars when C<$skip_latin> is set to a true value.

=back

=back

=head2 fix_encoding_return

Does and takes exactly the same as L</fix_encoding> but instead touching the
original supplied object it will clone it an return the new encoded object.

=head1 AUTHOR

BURNERSK <burnersk@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2014 by BURNERSK <burnersk@cpan.org>.

This is free software, licensed under:

  The MIT (X11) License

=cut
