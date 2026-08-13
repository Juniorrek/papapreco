# PapaPreco: working agreements

This file is committed on purpose. Project conventions live here rather than in
any assistant's local/machine-scoped memory, because this project is worked on
from more than one device and a convention that only exists on one of them is
not a convention.

The engineering plan lives in [docs/ROADMAP.md](docs/ROADMAP.md).

## Language

**Write all new code in English.** That includes identifiers, comments, doc
comments, test names, exception and log messages, commit messages, and
documentation.

The existing codebase is largely Portuguese: class names (`ProdutoRest`,
`VotoUsuarioProduto`), method names (`buscarPorNome`, `redefinirSenha`),
comments and exception strings. **Leave it alone.** It is not being renamed as
part of ongoing work; a wholesale rename is ~60 files of churn and is explicitly
out of scope in the roadmap. A dedicated refactor may be revisited later as its
own decision.

So, in practice:

- New file, new class, new function → English throughout.
- Editing an existing Portuguese function → keep its existing name and its
  callers' names; write any *new* comments and messages in English.
- Domain terms that are the ubiquitous language of the product (`produto`,
  `alerta`, `voto`, `nfce`) stay in Portuguese when they are the name of the
  domain concept, including in new code: `Produto`, not `Product`. Everything
  around them is English.

This mixed state is deliberate and transitional, not an oversight.

## Configuration

Nothing environment-specific is committed. All of it is passed at build time via
`--dart-define`; see the Configuration section of [README.md](README.md) for the
current list. `lib/rest/api.dart` is the single place the API address is
resolved. Call sites build URLs with `API.uri(path, [query])` and never
construct a host or scheme themselves.

## Before calling work done

```bash
flutter analyze   # compare against the count before your change; do not add new issues
flutter test
```
