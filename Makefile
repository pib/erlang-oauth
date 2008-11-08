SOURCE_FILES := $(wildcard src/*.erl)

ERLC := erlc -W +debug_info -o ebin

ERL := erl -pa ebin -pa ../erlang-fmt/ebin -s crypto -s inets -s ssl


all: beam_files

beam_files: $(SOURCE_FILES:src/%.erl=ebin/%.beam)

ebin/%.beam: src/%.erl
	@test -d ebin || mkdir ebin
	$(ERLC) $<

ebin/oauth_unit.beam: test/oauth_unit.erl
	$(ERLC) -pa ../eunit/ebin -I../ -Iinclude test/oauth_unit.erl

ebin/oauth_termie.beam: test/oauth_termie.erl
	$(ERLC) test/oauth_termie.erl

ebin/oauth_google.beam: test/oauth_google.erl
	$(ERLC) test/oauth_google.erl

clean:
	rm -rf ebin/*.beam erl_crash.dump

test: beam_files ebin/oauth_unit.beam
	@$(ERL) -noshell -s oauth_unit test -s init stop

termie_hmac: beam_files ebin/oauth_termie.beam
	@$(ERL) -noshell -s oauth_termie test_hmac -s init stop

termie_rsa: beam_files ebin/oauth_termie.beam
	@$(ERL) -noshell -s oauth_termie test_rsa -s init stop

google: beam_files ebin/oauth_google.beam
	@$(ERL) -noshell -s oauth_google test -s init stop

shell: beam_files
	@$(ERL)

dialyzer:
	dialyzer --no_check_plt --src -c src/
