use Fluent;
use Intl::BCP47;

my $x = LanguageTag.new('en');

my $l = localized('hello = Hello!
  .morning = Good morning!
  .night = Good evening!

goodbye = foo { DATE("blah",3.45,foo:12.34, bar : -49.375) }

messages = { $number ->
 [0] Sorry {$who}, you have no messages.
*[one] Hey {$who}, you have one message.
 [other] Hello {$who}!  You have {$number} messages.
 [42] Wow! You have the-answer-to-the-ultimate-question-of-life-the-university-and-everything messages!
}
');

#say "---------------";
#say "Messages: \n  ", $l.messages.values.map(*.gist).join("\n  ");
#say "Terms: \n  ", $l.terms.values.map(*.gist).join("\n  ");
#say "---------------";

# note, number selection should be for choosing, well,
# numbers.  Language selection will be handled in a different part.
# but this just makes it easy to see that the variable is parsed correctly.
say $l.format("messages", $x, :0number, :who('Adam'));
say $l.format("messages", $x, :1number, :who('John'));
say $l.format("messages", $x, :2number, :who('Jane'));
say $l.format("messages", $x, :3number, :who('Susan'));
say $l.format("messages", $x, :5number, :who('Karen'));
say $l.format("messages", $x, :42number, :who('Douglas'));

#about = About \{ -brand-name \}.
#")
#            [locative] Firefoxa
#*[nominative] Firefox
#about = Informacje o { -brand-name(case: "locative") }.
say " ---------- ";
