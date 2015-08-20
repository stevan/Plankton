# Plankton

`Plankton` is an alternate implementation of `Plack`-style 
middleware, that is *not-quite* PSGI compatible. That said
it is about 50% faster (see benchmarks).

The important distinction between `Plankton` and `Plack` is
that `Plankton` avoids always wrapping things in closures
(which is how it gets the speed bump of course). 

## Disclaimer

This is just an experiment, might become useful, we will have
to wait and see. 

## COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Stevan Little.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.