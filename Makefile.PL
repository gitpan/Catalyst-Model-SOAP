use 5.008008;
use ExtUtils::MakeMaker;
WriteMakefile
  (
   NAME              => 'Catalyst::Model::SOAP',
   VERSION_FROM      => 'lib/Catalyst/Model/SOAP.pm',
   PREREQ_PM         => { Catalyst::Runtime => 5.7011, XML::Compile::SOAP => 0 },
   ABSTRACT_FROM  => 'lib/Catalyst/Model/SOAP.pm',
   AUTHOR         => 'Daniel Ruoso <daniel.ruoso@verticalone.pt>',
  );
