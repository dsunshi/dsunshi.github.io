# Github Pages

## Usage

Posts in the `_posts/` directory are written in Markdown using [**Chirpy**][chirpy] / [Jekyll](https://jekyllrb.com/). This requires frontmatter that is not
supported by [markdown-unlit](https://github.com/sol/markdown-unlit), in order to load the posts in `ghci` the included `Makefile` can be used to copy posts
from `_posts/` to `Haskell/`. This will do two things:
 - Markdown files `*.md` are renamed as literate Haskell `.lhs`
 - The frontmatter in the original Markdown files is removed

```shell
.
├── _posts
├── _Haskell
```


The included `shell.nix` also creates an alias for `ghci` of `ghci -pgmL markdown-unlit`. This makes it possible in a `nix-shell` environment to run:

```shell
ghci Haskell/*.lhs
```

## License

This work is published under [MIT][LICENSE] License.
