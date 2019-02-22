use lib '../lib';
use lib 'lib';
use Test;
use Fluent;
use Fluent::Grammar;
use Fluent::Actions;



subtest "Identifier" => {
  ok  FTL.subparse("abc",         :rule('identifier'));
  ok  FTL.subparse("abc_123-xyz", :rule('identifier'));
  nok FTL.subparse("-abc",        :rule('identifier'));
  nok FTL.subparse("123abc",      :rule('identifier'));
  is  FTL.subparse("abç",         :rule('identifier')).Str, "ab";
}

subtest "Variant Key" => {
  ok FTL.subparse('[abc]', :rule('variant-key'));
  ok FTL.subparse('[    abc  ]', :rule('variant-key'));
  ok FTL.subparse('[
                        abc
                             ]', :rule('variant-key'));
  ok FTL.subparse('[ 123 ]', :rule('variant-key'));
}

subtest "Variant" => {
  ok FTL.subparse('
[abc] def', :rule('variant'));
  ok FTL.subparse('
    [    abc  ]  def', :rule('variant'));
  ok FTL.subparse('
    [
                        abc
                             ]def ', :rule('variant'));
  ok FTL.subparse('
   [ 123 ] def', :rule('variant'));
  ok FTL.parse('
     [ 123 ]
def', :rule('variant'));
}

subtest "Default Variant" => {
  ok FTL.subparse('
*[abc] def', :rule('default-variant'));
  ok FTL.subparse('
    *[    abc  ] def', :rule('default-variant'));
  ok FTL.subparse('
    *[
                        abc
                             ]def', :rule('default-variant'));
  ok FTL.subparse('
    *[ 123 ]  def', :rule('default-variant'));
  nok FTL.subparse('
  * [abc] def', :rule('default-variant'));
  ok FTL.subparse('
  *[abc]
def', :rule('default-variant'));
}

subtest "Variant List" => {
  ok FTL.subparse('
  *[abc] def
', :rule('variant-list'));
  ok FTL.subparse('
  [abc] def
  *[ghi] jkl
', :rule('variant-list'));
ok FTL.subparse('
  *[abc] def
   [ghi] jkl
', :rule('variant-list'));
ok FTL.subparse('
   [abc] def
  *[ghi] jkl
   [mno] pqr
', :rule('variant-list'));
is FTL.subparse('
  *[abc] def
  *[ghi] jkl
', :rule('variant-list')).Str, '
  *[abc] def
'; # should not capture the *[ghi] which would error in a full parse
}

subtest "Blank Block" => {
  ok FTL.subparse('
', :rule('blank-block'));
  ok FTL.subparse('
', :rule('blank-block'));
  ok FTL.subparse('

', :rule('blank-block'));
  is FTL.subparse('
  ', :rule('blank-block')), '
'; # should not match the spaces after the newline
}

subtest "Comment Line" => {
  ok FTL.parse('# abc
', :rule("comment-line"), :actions(FTLActions));
  ok FTL.parse('## abc
', :rule("comment-line"), :actions(FTLActions));
  ok FTL.parse('### abc
', :rule("comment-line"), :actions(FTLActions));
  nok FTL.parse('#### abc
', :rule("comment-line"), :actions(FTLActions));
  nok FTL.parse('#abc
', :rule("comment-line"), :actions(FTLActions));
  nok FTL.parse('# abc', :rule("comment-line"), :actions(FTLActions));
  ok FTL.parse('##
', :rule("comment-line"), :actions(FTLActions));
}

subtest "Number literal" => {
  ok FTL.subparse('123',      :rule('number-literal'));
  ok FTL.subparse('-456',     :rule('number-literal'));
  ok FTL.subparse('789.012',  :rule('number-literal'));
  ok FTL.subparse('-123.456', :rule('number-literal'));
  nok FTL.subparse('.7',      :rule('number-literal'));
  nok FTL.subparse('-.8',     :rule('number-literal'));
  nok FTL.subparse('+901.',   :rule('number-literal'));
  is  FTL.subparse('-234.',   :rule('number-literal')).Str, '-234';
}

subtest "String literal" => {
  ok  FTL.subparse('"abc"',            :rule('string-literal'), :actions(FTLActions));
  nok FTL.subparse("'abc'",            :rule('string-literal'), :actions(FTLActions));
  ok  FTL.subparse('"abc\\""',         :rule('string-literal'), :actions(FTLActions));
  ok  FTL.subparse('"abc\\\\"',        :rule('string-literal'), :actions(FTLActions));
  ok  FTL.subparse('"abc\\u1234"',     :rule('string-literal'), :actions(FTLActions));
  nok FTL.subparse('"abc\\U123456"',   :rule('string-literal'), :actions(FTLActions));
  ok  FTL.subparse('"abc\\U012345"',   :rule('string-literal'), :actions(FTLActions));
  nok  FTL.subparse('"abc\\u123"',     :rule('string-literal'), :actions(FTLActions));
  nok  FTL.subparse('"abc\\U12345"',   :rule('string-literal'), :actions(FTLActions));
  nok  FTL.subparse('"abc\\a"',        :rule('string-literal'), :actions(FTLActions));
  nok  FTL.subparse('abc',             :rule('string-literal'), :actions(FTLActions));
  nok  FTL.subparse('"abc',            :rule('string-literal'), :actions(FTLActions));
  nok  FTL.subparse('abc"',            :rule('string-literal'), :actions(FTLActions));
}

subtest "Text Character" => {
  ok  FTL.subparse("a", :rule('text-char'));
  nok FTL.subparse('{', :rule('text-char'));
  nok FTL.subparse('}', :rule('text-char'));
  nok FTL.subparse('
',                      :rule('text-char'));
}

subtest "Pattern" => {
  ok FTL.subparse("abc",               :rule('pattern-element:sym<inline-text>'));
  ok FTL.subparse("áßçđėģħĭĳĸŀŉƣƥρστжЖץהنغډդէޖߖߔࠖࠅࡅदधখগਕਦશષଥଧถธဖဘფღᏄᏇᜃᜆ⊅≋≬☣☦⻥⻪", :rule('pattern-element:sym<inline-text>'));
  ok FTL.subparse('{ abc }',           :rule('pattern-element:sym<inline-placeable>'));
  ok FTL.subparse('{ -123.456 }',      :rule('pattern-element:sym<inline-placeable>'));
  ok FTL.subparse('{ abc.efg }',       :rule('pattern-element:sym<inline-placeable>'));
  ok FTL.subparse('{ -abc }',          :rule('pattern-element:sym<inline-placeable>'));
  ok FTL.subparse('{ -abc.efg }',      :rule('pattern-element:sym<inline-placeable>'));
  ok FTL.subparse('{ -abc.efg(abc) }', :rule('pattern-element:sym<inline-placeable>'));
  ok FTL.subparse('{ $abc }',          :rule('pattern-element:sym<inline-placeable>'));
  ok FTL.subparse('{ {abc} }',         :rule('pattern-element:sym<inline-placeable>'));
}

subtest "Attribute" => {
  ok  FTL.subparse('
.abc=def', :rule('attribute'));
  ok  FTL.subparse('
.abc     = def', :rule('attribute'));
  nok FTL.subparse('.abc=def', :rule('attribute'));
  nok FTL.subparse('
abc.def=ghi', :rule('attribute'));
}

subtest "Term" => {
  ok FTL.subparse('-abc=def',                 :rule('term'));
  ok FTL.subparse('-abc    = def',            :rule('term'));
  ok FTL.subparse('-abc
                           =
                             def',            :rule('term'));
  ok FTL.subparse('-abc = { -123.456 }',      :rule('term'));
  ok FTL.subparse('-abc = { -abc.efg(abc) }', :rule('term'));
  ok FTL.subparse('-abc = abc
.abc = def',                                  :rule('term'));
}

subtest "Message" => {
  ok FTL.subparse('abc=def',      :rule('message'));
  ok FTL.subparse('abc   =  def', :rule('message'));
  ok FTL.subparse('abc
                         =
                            def', :rule('message'));

}
done-testing()