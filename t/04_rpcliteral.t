use Test::More tests => 3, todo => 3;
use Symbol;
use XML::Compile;
use XML::Compile::Transport::SOAPHTTP;
BEGIN { use_ok('Catalyst::Model::SOAP') };

use lib 't/lib/';
use TestTransport;

use XML::LibXML;
my $parser = XML::LibXML->new();
our $test_code;
{
  package MyFooModel;
  use base qw(Catalyst::Model::SOAP);
  __PACKAGE__->config->{transport} =
    TestTransport->new
      (sub {
         return $test_code->(@_);
       });
  __PACKAGE__->register_wsdl('t/hello4.wsdl', { Greet => 'Bar::Baz' });
};

# now we check if the body is consistent
$test_code = sub {
  my $message = shift->toString;
  ok($message =~ /Hello|World/g, 'Output message contain parameters.');

  return $parser->parse_string(<<SOAPMESSAGE);
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:hello="http://example.com/hello"><SOAP-ENV:Body><hello:Greet><hello:greeting>Hello World!</hello:greeting></hello:Greet></SOAP-ENV:Body></SOAP-ENV:Envelope>
SOAPMESSAGE

};
my $ret = MyFooModel::Bar::Baz->Greet
  ({ who => 'World', greeting => 'Hello' });

is($ret->{greeting}, 'Hello World!', 'Output message processed!');
