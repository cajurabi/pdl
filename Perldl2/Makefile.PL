use ExtUtils::MakeMaker;
PDL::Core::Dev->import();

my @podpms = map { $_.".pod", '$(INST_LIBDIR)/' . $_ .".pod"} qw/pdl2/;

# Make sure we have the PDL CONFIG hash loaded, and try to load it
# from perldl.conf if not.
use File::Spec;
unless (%PDL_CONFIG) {
	do File::Spec->catfile('..', 'perldl.conf') ;
	%PDL::Config = %PDL_CONFIG;
}

if (!defined $PDL::Config{WITH_DEVEL_REPL}) {
   if (eval 'require Devel::REPL;') {
      # Only generate Makefile if we have Devel::REPL
      WriteMakefile(
         'NAME' => 'PDL::Perldl2',
         'VERSION' => '2.000',
         'EXE_FILES' => [ 'pdl2' ],
         'DIR' => [ qw(Profile Plugin) ],
         'PM' => { 'Script.pm' => '$(INST_LIBDIR)/Perldl2/Script.pm', @podpms },
      );
   } else {
      # Devel::REPL was not found
      $PDL::Config{WITH_DEVEL_REPL} = 0;
      $msg = "Devel::REPL is not installed, will not build Perldl2 shell";
      print STDERR "$msg\n";
      write_dummy_make($msg);
   }
}
elsif ($PDL::Config{WITH_DEVEL_REPL}) {
  # They want it, so make it
  WriteMakefile(
	 'NAME' => 'PDL::Perldl2',
	 'VERSION' => '2.000',
	 'EXE_FILES' => [ 'pdl2' ],
	 'DIR' => [ qw(Profile Plugin) ],
         'PM' => { 'Script.pm' => '$(INST_LIBDIR)/Perldl2/Script.pm', @podpms },
  );
}
else {
	# they don't want it, so generate a dummy
	write_dummy_make('Not making or installing Perldl2 shell, per configuration');
}
# Extra build target to build the doc database
sub MY::postamble {
   my  $text = '';

   $text .= << "EOPS" ;

pdl2.pod : pdl2 subdirs
\t\$(PERLRUN) -MPod::Select -e "podselect('pdl2');" > pdl2.pod

EOPS

   return $text;

}
