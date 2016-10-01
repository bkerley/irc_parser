-module(irc_parser_tests).

-include_lib("eunit/include/eunit.hrl").
-include_lib("irc_parser.hrl").

-define(expect_parse_(Message, Expected),
        ?_assertEqual(Expected, irc_parser:parse(Message))).

motd_test_() ->
    Expectation = #ircmesg{
                     prefix="asdf.irc",
                     command="372",
                     params=[
                             "somenick",
                             "- motd text"]},
    ?expect_parse_(":asdf.irc 372 somenick :- motd text", Expectation).

privmesg_test_() ->
    Expectation = #ircmesg{
                     command="PRIVMSG",
                     params=["#channel", "hello"]},
    PrefixExpectation = Expectation#ircmesg{prefix="asdf.irc"},
    [?expect_parse_(":asdf.irc PRIVMSG #channel hello", PrefixExpectation),
     ?expect_parse_("PRIVMSG #channel hello", Expectation),
     ?expect_parse_("PRIVMSG #channel :hello", Expectation),
     ?expect_parse_(":asdf.irc PRIVMSG #channel :hello", PrefixExpectation)].
