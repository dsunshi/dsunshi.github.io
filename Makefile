Haskell/srec_part0.lhs: _posts/2025-07-30-Haskell_srec_part0.md
	cp $< $@
	sed -i '1{/^---$$/! q;};1,/^---$$/d' $@

clean: Haskell/srec_part0.lhs
	rm $<

serve:
	bundle exec jekyll serve
