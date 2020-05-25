# microwiki

Like [vimwiki](https://github.com/vimwiki/vimwiki), but for 
[micro](https://github.com/zyedidia/micro).

## Features
- Extend `markdown` syntax
  - recognize `[[wiki link]]` as a link
  - code block syntax highlighting for some languages ([zyedidia/micro#1083](https://github.com/zyedidia/micro/issues/1083), [zyedidia/micro#1540](https://github.com/zyedidia/micro/pull/1540))
- `Alt-Enter`: Open file in new tab. If the file does not exist, it will create
  it. Ideally would use `Ctrl-Enter`, but [zyedidia/micro#1328](https://github.com/zyedidia/micro/issues/1328).
- `Alt-Backspace`: Save current file and close tab. I would use `Ctrl-Backspace`,
  but that doesn't work.
- `Ctrl-Space`: Gives file autocompletion when cursor is inside a `[[wiki link]]`
  based on the current file and the contents of the `[[wiki link]]` i.e. 
  `<current dir>/<wiki link>/`. If the wiki link is empty (`[[]]`), it will 
  suggest files and directories at `<current dir>/`. If the wiki link is 
  `[[Class notes]]`, it will suggest files and directories at 
  `<current dir>/Class notes/`.

## Useful links

Links might be useful for plugin development.

- [Micro plugin documentation](https://github.com/zyedidia/micro/blob/v2.0.4/runtime/help/plugins.md)
- [Lua online](https://www.lua.org/cgi-bin/demo)
- [Lua manual](https://www.lua.org/manual/5.3/manual.html)
- [Micro available imports](https://github.com/zyedidia/micro/blob/v2.0.4/cmd/micro/initlua.go)
- [More micro imports](https://github.com/zyedidia/micro/blob/v2.0.4/internal/lua/lua.go)

### Micro v2 plugins
- [Comment](https://github.com/zyedidia/micro/blob/v2.0.4/runtime/plugins/comment/comment.lua)
- [Go](https://github.com/micro-editor/go-plugin/blob/v2.0.2/go.lua)
- [Literate](https://github.com/zyedidia/micro/blob/v2.0.4/runtime/plugins/literate/literate.lua)
- [Linter](https://github.com/zyedidia/micro/blob/v2.0.4/runtime/plugins/linter/linter.lua)


### Micro v1 plugins
- [Filemanager](https://github.com/NicolaiSoeborg/filemanager-plugin/blob/v3.4.0/filemanager.lua)
- [Snippets](https://github.com/zyedidia/microsnippets/blob/6c4e55e419fb3abb411e3febb0a14ef837a7a143/snippets.lua)