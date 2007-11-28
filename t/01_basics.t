
use Test::More tests => 9;
use Symbol;
BEGIN { use_ok('Catalyst::Model::SOAP') };

use lib 't/lib/';
use MyXMLModule;

{
    package MyFooModel;
    use base qw(Catalyst::Model::SOAP);
    __PACKAGE__->register_wsdl('http://foo.bar/baz.wsdl', 'Bar::Baz');
};

{
    package Catalyst::Model::SOAP::Instance;
    sub foo {
        return 'ok';
    }
};

ok(defined @MyFooModel::Bar::Baz::ISA, 'Loading the wsdl pre-registers the class.');
is(MyFooModel::Bar::Baz->foo(), 'ok', 'The dynamic class isa Catalyst::Model::SOAP::Instance.');
ok(defined &MyFooModel::Bar::Baz::op1, 'Loading the wsdl pre-registers the method.');
ok(defined &MyFooModel::Bar::Baz::_op1_data, 'Loading the wsdl pre-register the helper-method');
is(MyFooModel::Bar::Baz->op1, 'op1', 'The method calls the coderef.');
my @data = MyFooModel::Bar::Baz->_op1_data();
is(ref $data[0], 'MyXML::WSDL11', 'The first element in the data is the wsdl object');
is(ref $data[1], 'MyXML::Operation', 'The second element in the data is the operation object');
is(ref $data[2], 'CODE', 'The third element in the data is the code reference');
