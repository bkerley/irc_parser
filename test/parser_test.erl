-module(parser_test).

-include_lib("eunit/include/eunit.hrl").
-include_lib("irc_parser.hrl").

-define(expect_parse_(Message, Expected),
        Got = irc_parser:parse(Message),
        ?_assertEqual(Expected, Got)).

motd_test_() ->
    Expectation = #ircmesg{
                     prefix="asdf.irc",
                     command="372",
                     params=[
                             "somenick",
                             "- motd text"]},
    ?expect_parse_(":asdf.irc 372 somenick :- motd text", Expectation).
