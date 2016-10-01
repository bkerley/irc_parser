-module(irc_parser).

-include_lib("irc_parser.hrl").

-export([parse/1]).

parse(Mesg) when is_binary(Mesg) ->
    parse(binary_to_list(Mesg));
parse(Mesg) when is_list(Mesg)->
    parse(start, #ircmesg{}, Mesg).

parse(start, Accum, [$: | Remain]) ->
    parse(prefix, Accum, Remain);
parse(start, Accum, Mesg) ->
    parse(command, Accum, Mesg);

parse(prefix, _, "") ->
    throw({badmessage, "The IRC message had no command - just a prefix."});
parse(prefix, Accum, [$ |Remain]) -> % space ends prefix
    BackPfx = Accum#ircmesg.prefix,
    FwdPfx = lists:reverse(BackPfx),
    NewAccum = Accum#ircmesg{prefix=FwdPfx},
    parse(space_command, NewAccum, Remain);
parse(prefix, Accum, [Cur|Remain]) -> % continue eating prefix
        OldPrefix = Accum#ircmesg.prefix,
        NewPrefix = [Cur|OldPrefix],
        NewAccum = Accum#ircmesg{prefix=NewPrefix},
        parse(prefix, NewAccum, Remain);

parse(space_command, Accum, [$ |Remain]) -> % continue eating spaces
        parse(space_command, Accum, Remain);
parse(space_command, Accum, Mesg) -> % onwards to message
        parse(command, Accum, Mesg);

parse(command, Accum, "") ->
        reverse_cmd(Accum);
parse(command, Accum, [$ |Remain]) -> % space ends command, continue to params
        parse(space_params, reverse_cmd(Accum), Remain);
parse(command, Accum, [Cur|Remain]) -> % continue eating command
        OldCommand = Accum#ircmesg.command,
        NewCommand = [Cur|OldCommand],
        NewAccum = Accum#ircmesg{command=NewCommand},
        parse(command, NewAccum, Remain);

parse(space_params, Accum, "") ->
        Accum;
parse(space_params, Accum, [$ |Remain]) ->
        parse(space_params, Accum, Remain);
parse(space_params, Accum, Mesg) ->
        Params = params_parse(Mesg),
        Accum#ircmesg{params=Params}.

params_parse(Mesg) ->
        params_parse([], [], Mesg).

%end of string
params_parse(Accum, [], []) ->
        lists:reverse(Accum);
params_parse(Accum, Cur, []) ->
        params_parse([lists:reverse(Cur)|Accum], [], []);

%end of param
params_parse(Accum, [], [$ |Remain]) ->
        params_parse(Accum, [], Remain);
params_parse(Accum, Cur, [$ |Remain]) ->
        params_parse([lists:reverse(Cur)|Accum], [], Remain);

%remain
params_parse(Accum, [], [$:|Remain]) ->
        params_parse([Remain|Accum], [], []);

%normal
params_parse(Accum, Cur, [First|Rest]) ->
        params_parse(Accum, [First|Cur], Rest).

reverse_cmd(Rec) ->
        Back = Rec#ircmesg.command,
        Fwd = lists:reverse(Back),
        Rec#ircmesg{command=Fwd}.
