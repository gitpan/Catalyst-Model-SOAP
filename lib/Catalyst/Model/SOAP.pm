{   package Catalyst::Model::SOAP;
    use strict;
    use warnings;
    use XML::Compile::WSDL11;
    use base qw(Catalyst::Model);
    our $VERSION = '0.0.5';
    sub register_wsdl {
        my ($self, $wsdl, $target) = @_;

        my $wsdl_obj;
        my $schema;

        if (ref $wsdl eq 'HASH') {
            $schema = $wsdl->{schema};
            $wsdl = $wsdl->{wsdl}
        }

        if (ref $wsdl eq 'ARRAY') {
            my $main = shift @{$wsdl};
            $wsdl_obj = XML::Compile::WSDL11->new($main);
            $wsdl_obj->addWSDL($_) for @{$wsdl};
        } else {
            $wsdl_obj = XML::Compile::WSDL11->new($wsdl);
        }

        if (ref $schema eq 'ARRAY') {
            $wsdl_obj->importDefinitions($_) for @{$schema};
        } elsif ($schema) {
            $wsdl_obj->importDefinitions($schema)
        }

        my $realtarget = $self.'::'.$target;

        no strict 'refs';
        @{$realtarget.'::ISA'} = qw(Catalyst::Model::SOAP::Instance);
        foreach my $operation ($wsdl_obj->operations(produce => 'OBJECTS')) {
            my $code = $operation->compileClient();
            *{$realtarget.'::'.$operation->name()} = sub {
                my $self = shift;
                return $code->(@_);
            };
            *{$realtarget.'::_'.$operation->name().'_data'} = sub {
                return ($wsdl_obj, $operation, $code);
            };
        }
    }
};
{   package Catalyst::Model::SOAP::Instance;
    use strict;
    use warnings;
    use base qw(Catalyst::Model);
}
1;

__END__

=head1 NAME

Catalyst::Model::SOAP - Map a WSDL to a catalyst model class.

=head1 SYNOPSIS

  {# In the model class...
      package MyApp::Model::SOAP;
      use base qw(Catalyst::Model::SOAP);
      __PACKAGE__->register_wsdl('http://foo.bar/baz.wsdl', 'Baz');
      __PACKAGE__->register_wsdl('http://baz.bar/foo.wsdl', 'Foo');

      # use several wsdl files
      __PACKAGE__->register_wsdl([ $file1, $file2, $file3 ], 'Baz');

      # and or register schemas
      __PACKAGE__->register_wsdl({ wsdl => $scalar_or_array,
            schema => $scalar_or_array }, 'Bla');
  };
  {# later in some other class..
     $c->model('SOAP::Baz')->getWeather(%arguments);
     # is then dispatched to the operation getWeather described by the
     # first wsdl...
     $c->model('SOAP::Foo')->foo(%arguments);
     # is then dispatched to the operation foo described by the
     # second wsdl...
  };

=head1 ABSTRACT

Create a catalyst model class from a WSDL definition using
XML::Compile::SOAP.

=head1 DESCRIPTION

This module implements a mapping from a wsdl definition, interpreted
by XML::Compile::SOAP::WSDL, as a Model class, where each operation in
the wsdl file is represented by a method with the same name.

=head1 METHODS

=over

=item register_wsdl($wsdl, $targetclass)

This method will register the operations described by $wsdl in the
$targetclass package. $wsdl may be anythin XML::Compile::SOAP::WSDL11
accepts. The $targetclass is a relative package name which will be
concatenated in the name of the model.

If $wsdl is an arrayref, the first element is the one passed to new,
and the others will be the argument to subsequent addWsdl calls.

If $wsdl is a hashref, the "wsdl" key will be handled like above and
the "schema" key will be used to importDefinitions. If the content of
the schema key is an arrayref, it will result in several calls to
importDefinition.

Note that XML::Compile->knownNamespace(...) can be used to help
declaring the wsdl.

=back

=head1 ACCESSORS

For each operation, a secondary method called _$operation_data is
created. This method returns a list composed by the WSDL object, the
operation object and the compiled code ref.

=head1 INVOCATION

The invocation schema for each operation is documented in
XML::Compile::SOAP. Each method is a closure that will call the
coderef with the parameters ($self excluded).

=head1 XML::Compile::SOAP x SOAP::WSDL

For this module, there were two options on the SOAP client
implementation. XML::Compile::SOAP and SOAP::WSDL. While both
implement all the features expected by this module, the reason to
choose XML::Compile::SOAP over SOAP::WSDL resides in the hability to
support the specs more closely in the future. And also to provide a
better support to handle literal XML messages. As the SOAP::WSDL
documentation already states, XML::Compile::SOAP provides an approach
much more extensible and close to the specs than SOAP::WSDL.

Another version of this module may be implemented in the future
supporting the other module, but, as for the relationship between
Catalyst::Controller::SOAP and Catalyst::Model::SOAP,
XML::Compile::SOAP seems to make more sense.

=head1 SEE ALSO

L<Catalyst::Controller::SOAP>, L<XML::LibXML>, L<XML::Compile::SOAP>

=head1 AUTHORS

Daniel Ruoso C<daniel.ruoso@verticalone.pt>

=head1 BUG REPORTS

Please submit all bugs regarding C<Catalyst::Model::SOAP> to
C<bug-catalyst-model-soap@rt.cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.


=cut

