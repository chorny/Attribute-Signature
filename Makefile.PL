use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Attribute::Signature',
    'VERSION_FROM'	=> 'lib/Attribute/Signature.pm', # finds $VERSION
    'PREREQ_PM'		=> {
			    Attribute::Handlers => 0.70,
			    Scalar::Util        => 0.01,
			   }, # e.g., Module::Name => 1.1
    'LIBS'		=> [''], # e.g., '-lm'
    'DEFINE'		=> '', # e.g., '-DHAVE_SOMETHING'
    'INC'		=> '', # e.g., '-I/usr/include/other'
);
