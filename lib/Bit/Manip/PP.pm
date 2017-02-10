package Bit::Manip::PP;

use warnings;
use strict;

our $VERSION = '1.05';

use Exporter;
our @ISA = qw(Exporter);

our @EXPORT_OK = qw(
    bit_get
    bit_set
    bit_clr
    bit_toggle
    bit_on
    bit_off
    bit_bin
    bit_count
    bit_mask
);

our %EXPORT_TAGS;
$EXPORT_TAGS{all} = [@EXPORT_OK];

sub _ref {
    shift if @_ == 2;
    if ($_[0] !~ /^\d+$/ && ref $_[0] ne 'SCALAR'){
        die "your data must either be an integer or a SCALAR reference\n";
    }

    if (ref $_[0]){
        if (${ $_[0] } !~ /^\d+/){
            die "data reference must contain only an integer\n";
        }
        return 1;
    }
    return 0;
}
sub bit_bin {
    my ($data) = @_;
    return sprintf("%b", $data);
}
sub bit_count {
    my ($n, $set) = @_;

    if (! defined $n || $n !~ /^\d+/){
        die "bit_count() requires an integer param\n";
    }

    my $bits = sprintf("%b", $n);
    my $bit_count;

    if ($set){
        $bit_count = $bits =~ tr/1/1/;
    }
    else {
        $bit_count = length($bits);
    }

    return $bit_count;
}
sub bit_mask {
    my ($bits, $lsb) = @_;
    return (2 ** $bits - 1) << $lsb;
}
sub bit_get {
    my ($data, $msb, $lsb) = @_;

    $lsb = 0 if ! defined $lsb;

    _check_msb($msb);
    $msb++; # need to start from 1 here

    _check_lsb($lsb, $msb);

    return ($data & (2**$msb-1)) >> $lsb;
}
sub bit_set {
    my ($data, $lsb, $bits, $value) = @_;

    if (@_ != 4){
        die "bit_set() requires four params\n";
    }

    _check_value($value);

    my $value_bits = bit_count($value, 0);
    if ($value_bits != $bits){
        $value_bits = $bits;
    }
    my $mask = bit_mask($value_bits, $lsb);

    if (_ref($data)){
        $$data = ($$data & ~($mask)) | ($value << $lsb);
        return 0;
    }
    else {
        $data = ($data & ~($mask)) | ($value << $lsb);
        return $data;
    }
}
sub bit_clr {
    my ($data, $lsb, $nbits) = @_;
    return bit_set($data, $lsb, $nbits, 0);
}
sub bit_toggle {
    my ($data, $bit) = @_;

    if (_ref($data)){
        $$data ^= 1 << $bit;
        return 0;
    }
    else {
        return $data ^= 1 << $bit;
    }
}
sub bit_on {
    my ($data, $bit) = @_;

    if (_ref($data)){
        $$data |= 1 << $bit;
        return 0;
    }
    else {
        return $data |= 1 << $bit;
    }
}
sub bit_off {
    my ($data, $bit) = @_;

    if (_ref($data)){
        $$data &= ~(1 << $bit);
        return 0;
    }
    else {
        return $data &= ~(1 << $bit);
    }
}
sub _check_msb {
    my ($msb) = @_;
    if ($msb < 0){
        die("\$msb param can not be negative\n");
    }
}
sub _check_lsb {
    my ($lsb, $msb) = @_;

    if ($lsb < 0){
        die "\$lsb param can't be negative\n";
    }
    if (($lsb + 1) >= $msb){
        die "\$lsb param must be less than \$msb\n";
    }
}
sub _check_value {
    shift if @_ > 1;
    my ($val) = @_;
    if ($val < 0){
        die "\$value param must be zero or greater\n";
    }
}
sub _vim{};

1;
__END__

=head1 NAME

Bit::Manip::PP - Pure Perl functions to simplify bit string manipulation

=for html
<a href="http://travis-ci.org/stevieb9/bit-manip-pp"><img src="https://secure.travis-ci.org/stevieb9/bit-manip-pp.png"/>
<a href='https://coveralls.io/github/stevieb9/bit-manip-pp?branch=master'><img src='https://coveralls.io/repos/stevieb9/bit-manip-pp/badge.svg?branch=master&service=github' alt='Coverage Status' /></a>

=head1 SYNOPSIS

    use Bit::Manip::PP qw(:all);

    my $b;    # bit string
    $b = 128; # 10000000

    $b = bit_toggle($b, 4); # 10010000
    $b = bit_toggle($b, 4); # 10000000

    bit_toggle(\$b, 4); # same as above, but with a reference

    $b = bit_off($b, 7);    # 0 
    $b = bit_on($b, 7);     # 10000000 

    bit_off(\$b, 7);
    bit_on(\$b, 7);

    # get the value of a range of bits...
    # in this case, we'll print the value of bits 4-3

    $b = 0b00111000; (56)

    print bit_get($b, 4, 3); # 3

    # set a range of bits...
    # let's set bits 4-2 to binary 101

    $b = 0b10000000;

    $b = bit_set($b, 2, 3, 0b101); # 10010100

    bit_set(\$b, 2, 3, 0b101); # reference

    # clear some bits

    $b = 0b11111111;

    $num_bits = 3;
    $lsb = 3;

    $b = bit_clr($b, $lsb, $num_bits); # 11000111

    bit_clr(\$b, $lsb, $num_bits); # reference

    # helpers

    my ($num_bits, $lsb) = (3, 2);
    print bit_mask($num_bits, $lsb); # 28, or 11100

    print bit_bin(255); # 11111111 (same as printf("%b", 255);)


=head1 DESCRIPTION

This is the Pure Perl version of the XS-based L<Bit::Manip> distribution.

Provides functions to aid in bit manipulation (set, unset, toggle, shifting)
etc. Particularly useful for embedded programming and writing device
communication software.

Currently, up to 32-bit integers are supported.

=head1 EXPORT_OK

Use the C<:all> tag (eg: C<use Bit::Manip::PP qw(:all);>) to import the
following functions into your namespace, or pick and choose individually:

    bit_get 
    bit_set
    bit_clr
    bit_toggle
    bit_on
    bit_off
    bit_bin
    bit_count
    bit_mask

=head1 FUNCTIONS

=head2 bit_get

Retrieves the value of specified bits within a bit string.

Parameters:

    $data

Mandatory: Integer, the bit string you want to send in. Eg: C<255> for
C<11111111> (or C<0xFF>).

    $msb

Mandatory: Integer, the Most Significant Bit (leftmost) of the group of bits to
collect the value for (starting from 0 from the right, so with C<1000>, so you'd
send in C<3> as the start parameter for the bit set to C<1>). Must be C<1>

    $lsb

Optional: Integer, the Least Significant Bit (rightmost) of the group of bits to
collect the value for (starting at 0 from the right). A value of C<0> means
return the value from C<$msb> through to the very end of the bit string. A
value of C<1> will capture from C<$msb> through to bit C<1> (second from
right). This value must be equal to or lower than C<$msb>.

Return: Integer, the modified C<$data> param.

=head2 bit_set

Allows you to set a value for specific bits in your bit string.

Parameters:

    $data

Mandatory: Integer, the bit string you want to manipulate bits in. Optionally,
send in a reference to the scalar, and we'll work directly on it instead of
passing by value and getting the updated value returned.

    $lsb

Mandatory: Integer, the least significant bit (rightmost) in the bit range you
want to manipulate. For example, if you wanted to set a new value for bits
C<7-5>, you'd send in C<5>.

    $bits

Mandatory: Integer, the number of bits you plan on setting. This is so that any
leading zeros are honoured.

    $value

Mandatory: Integer, the value that you want to change the specified bits to.
Easiest if you send in a binary string (eg: C<0b1011> in Perl).

Return: Integer, the modified C<$data> param if <C$data> is passed in by value,
or C<0> if passed in by reference.

Example: 

You have an 8-bit register where the MSB is a start bit, and the rest
of the bits are zeroed out:

    my $data = 0b10000000; # (0x80, or 128)

The datasheet for the hardware you're writing to requires you to set bits 
C<6-4> to C<111> in binary (always start from bit 0, not 1):

    10000000
     ^^^   ^
     6-4   0

Code:

    my $x = bit_set($data, 4, 3, 0b111); # (0x07, or 7)
    printf("%b\n", $x); # prints 11110000

=head2 bit_clr

Clear (unset to 0) specific bits in the bit string.

Parameters:

    $data

Mandatory: Integer, the bit string you want to manipulate bits in. Optionally,
send in a reference to the scalar, and we'll work directly on it instead of
passing by value and getting the updated value returned.

    $lsb

Mandatory: Integer, the least significant bit (rightmost) in the bit range you
want to manipulate. For example, if you wanted to clear bits C<7-5>, you'd send
in C<5>.

    $nbits

Mandatory: Integer, the number of bits you're wanting to clear, starting from
the C<$lsb> bit, and clearing the number of bits to the left.

Return: Integer, the modified C<$data> param if <C$data> is passed in by value,
or C<0> if passed in by reference.

=head2 bit_toggle

Toggles a single bit. If it's C<0> it'll toggle to C<1> and vice-versa.

Parameters:

    $data

Mandatory: Integer, the number/bit string to toggle a bit in. Optionally,
send in a reference to the scalar, and we'll work directly on it instead of
passing by value and getting the updated value returned.

    $bit

Mandatory: Integer, the bit number counting from the right-most (LSB) bit
starting from C<0>.

Return: Integer, the modified C<$data> param if <C$data> is passed in by value,
or C<0> if passed in by reference.

=head2 bit_on

Sets a single bit (sets to C<1>), regardless of its current state.

Parameters:

    $data

Mandatory: Integer, the number/bit string to toggle a bit in. Optionally,
send in a reference to the scalar, and we'll work directly on it instead of
passing by value and getting the updated value returned.

    $bit

Mandatory: Integer, the bit number counting from the right-most (LSB) bit
starting from C<0>.

Return: Integer, the modified C<$data> param if <C$data> is passed in by value,
or C<0> if passed in by reference.

=head2 bit_off

Unsets a single bit (sets to C<0>), regardless of its current state.

Parameters:

    $data

Mandatory: Integer, the number/bit string to toggle a bit in. Optionally,
send in a reference to the scalar, and we'll work directly on it instead of
passing by value and getting the updated value returned.

    $bit

Mandatory: Integer, the bit number counting from the right-most (LSB) bit
starting from C<0>.

Return: Integer, the modified C<$data> param if <C$data> is passed in by value,
or C<0> if passed in by reference.

=head2 bit_mask

Generates a bit mask for the specific bits you specify.

Parameters:

    $bits

Mandatory: Integer, the number of bits to get the mask for.

    $lsb

Mandatory: Integer, the LSB at which you plan on implementing your change.

Return: Integer, the bit mask ready to be applied.

=head2 bit_bin

Returns the binary representation of a number as a string of ones and zeroes.

Parameters:

    $data

Mandatory: Integer, the number you want to convert.

=head2 bit_count

Returns either the total count of bits in a number, or just the number of set
bits (if the C<$set>, parameter is sent in and is true).

Parameters:

    $num

Mandatory: Unsigned integer, the number to retrieve the total number of bits
for. For example, if you send in C<15>, the total number of bits would be C<4>,
likewise, for C<255>, the number of bits would be C<16>.

    $set

Optional: Integer. If this is sent and is a true value, we'll return the number
of *set* bits only. For example, for C<255>, the set bits will be C<8> (ie. all
of them), and for C<8>, the return will be C<1> (as only the MSB is set out of
all four of the total).

Return: Integer, the number of bits that make up the number if C<$set> is C<0>,
and the number of set bits (1's) if C<$set> is true.

=head1 AUTHOR

Steve Bertrand, C<< <steveb at cpan.org> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2017 Steve Bertrand.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.

