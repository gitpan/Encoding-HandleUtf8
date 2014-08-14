requires "Carp" => "0";
requires "Clone" => "0";
requires "Encoding::FixLatin" => "0";
requires "Exporter" => "0";
requires "base" => "0";
requires "perl" => "5.010";

on 'test' => sub {
  requires "Test::More" => "1.001003";
  requires "Test::NoWarnings" => "0";
};

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "0";
};
