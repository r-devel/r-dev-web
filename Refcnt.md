# Notes on Reference Counting in R

As of r65048 R-devel can be compiled to use reference counting instead
of the `NAMED` mechanism to determine when objects can be modified in
place or need to be copied.  For now `NAMED` is the default. To switch
to using reference counting compile with `SWITCH_TO_REFCNT` defined,
or uncomment the line

```c
//#define SWITCH_TO_REFCNT
```

in `include/Rinternals.h`.


## Motivation

The motivation for this is to allow us to be able to decrement
reference counts that go above 1 to help reduce copying and maybe even
get to a point where efficient replacement functions can be written in
R.

Reference counting is also _much_ easier to understand and think about
than the NAMED mechanism.  Given that reference counts are managed
correctly by default and the exceptions are explicit it is fairly easy
to review the whole mechanism.  In contrast, with NAMED one has to
find the paces where NAMED adjustments might be needed but are
missing, which is much harder.


## A Caution for C Code that Modifies its Arguments

A small number of packages contain C functions called via the `.Call`
interface that internally check `NAMED` on an argument and modify the
argument directly if the `NAMED` value permits this. These packages
may need to be more careful or more conservative: In

```R
x <- list(1 + 2)
y <- x
.Call("foo", x[[1]])
```

the value received by `foo` would have `NAMED = 2`, since the
expression `x[[1]]` propagates the `NAMED` value of the container `x`
to the extracted element. Reference counting only reflects the
immediate references, so the reference count on the value received by
`foo` will be one. This means that, except in very special and well
understood circumstances, an argument passed down to C code should not
be modified if it has a positive refrence count, even if that count is
equal to one.

Only a few packages on CRAN and BIOC call `NAMED` or `SET_NAMED`, so
screening these for possible issues should be fairly easy.


## Performance

Switching to reference counting seems to have a rather negligible
performance impact. On one Linux box I see a 5% hit for tight scalar
loop code, on another I see no measurable difference. The table below
shows some results for the the first Linux box.  The impact on
vectorized code is of course even less. Even an across the board 5%
hit seems worth while to me for the simplification this change would
bring.

|      | REFCNT|NAMED
|------|------:|-----:
|p1    | 10.39 | 9.90
|p1c   |  3.07 | 3.18
|sm    |  2.06 | 1.91
|smc   |  0.46 | 0.43
|conv  |  4.47 | 4.30
|cconv |  1.25 | 1.33


## Design and Details

The main place reference counts are manipulated is in `memory.c` in
exactly the same places where the write barrier is managed.  When a
new value is placed in a vector or `CONS` cell field the reference
count on the new value is incremented and the reference count on the
previous value is decremented.

In addition, there are a few places that need to not increment reference
counts, like

 * .Last.value
 * places holding LHS in complex assignments
 * pairlists of arguments passed to builtin's

To accomplish this every object has a `TRACKREFS` flag; references to
the object's fields are only counted if `TRACKREFS` is true. The
function `CONS_NR` produces a `CONS` cell that does not track
references; these are used for internal argument lists and the like.
Many of the uses of `CONS_NR` could be eliminated by using a stack for
passing arguments.

There are also a few places where reference counts can safely be
decremented, like

 * RHS of an assignment at the end of a complex assignment sequence
 * The sequence in a `for` loop at the end of the loop
 * when contents of `x` is copied to `y` and `x` is discarded
   (growing/shrinking vectors)

Other opportunities for decrementing reference counts exist as well
but have not yet been addressed.


### Reference Counting Macros

The core macros implementing reference counting are

 * `REFCNT(x)` and `SET_REFCNT(x, v)`
 * `TRACKREFS(x)` and `SET_TRACKREFS(x, v)`
 * `REFCNTMAX`

As a rule the values of the `REFCNT` and `TRACKREFS` fields should
only be changed using the higher level macros

 * `INCREMENT_REFCNT(x)` and `DECREMENT_REFCNT(x)`
 * `DISABLE_REFCNT(x)` and `ENABLE_REFCNT(x)`


### Supporting Changes

To support the transition a number of standard use idioms for `NAMED`
and `SET_NAMED` have been replaced by macros that can also be defined
in terms of reference counts:

 * `NAMED(x) == 2` or `NAMED(x) > 1` becomes `MAYBE_SHARED(x)`
 * `NAMED(x) == 0` becomes `NO_REFERENCES(x)`
 * `NAMED(x) != 0` becomes `MAYBE_REFERENCED(x)`
 * `SET_NAMED(x, 2)` can be replaced by `MARK_NOT_MUTABLE(x)`

With these changes in place the initial implementation of reference
counting treats the remaining calls to `NAMED` as equivalent to calls
to `REFCNT`, and `SET_NAMED` becomes a no-op. Some of the
`SET_NAMED(x, 2)` calls could be replaced by `MARK_NOT_MUTABLE(x)`,
but this does not appear to be necessary.

All remaining uses of `NAMED` and `SET_NAMED` will need to be
thoroughly reviewed before completing the transition.


### Binary Compatibility

The same binary format is used as for the `NAMED` mechanism, with the
two bits of the `named` field used for the reference count. That means
reference counts stick at the maximal value of 3. Some rearranging of
the header would allow us to use a larger maximal reference count.


### Files Changed
Major changes:

 * `include/Rinternals.h`: macro definitions

 * `main/eval.c:` `CONS_NR` uses in argument lists; changes in the
   complex assignment code; decrementing of reference counts in some
   places.

 * `main/memory.c`: core implementation of reference count adjustment,
   along side the write barrier maintenance.

Minor changes:

 * `main/inspect.c`: Show `REF` values instead of `NAM` values.

 * `main/match.c:` In `matchArgs` use `CONS_NR` to build up argument
   lists that are only used internally and so should not increment
   reference counts.

 * `main/names.c`: Mark `.Last.value symbol to not increment reference
   counts.

 * `main/subassign.c`: In local function `R_DispatchOrEvalSP`
   decrement reference count on object after dispatch. Also, when
   extending vectors do not increment reference counts when copying
   objects from the old vector into the new one since the old one will
   be discarded.

 * `main/subset.c`: In local function `R_DispatchOrEvalSP` decrement
   reference count on object after dispatch.


### Complex Assignment Changes

Under the `NAMED` approach R level component extraction function
propagate the `NAMED` value of the container to the extracted
element. So duplicating of LHS values can be deferred until the
replacement functions are called. With reference counting duplicating
is necessary of an object itself or any of its containing LHS values
has a reference count greater than one. The simplest way to deal with
this is to duplicate as needed as new intermediate LHS values are
extracted. This is tone in `evalseq` for interpreted code. For byte
compiled code it is done in the `SWAP` instruction for now, since this
is only used between LHS extractions. This instruction should be
renamed to reflect this usage.
