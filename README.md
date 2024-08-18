## dart_mmd

A set of utilities to read MikuMikuDance formats for Flutter and Dart projects. Includes a reference implementation of an application that can load and display MMD models and sequences.

## Developing

### Codespaces/IDX

Click on the following Buttons to launch the project in IDX and GitHub Codespaces:



[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/sr229/dart_mmd) [![Open in IDX](https://cdn.idx.dev/btn/open_dark_32.svg)](https://idx.google.com/import?url=https%3A%2F%2Fgithub.com%2Fsr229%2Fdart_mmd)

### Locally

You need the [FVM](https://fvm.app/) tool to manage the Flutter SDK version. After installing it, run `fvm use` to install the correct version of the Flutter SDK.

After that, install [Melos](https://melos.invertase.dev/getting-started) and run `melos bootstrap` to initialise the whole project.

#### To develop the parser only

It's possible to just develop only the parser library -- all you need to do is install the appropriate Dart SDK, `cd` to `packages/mmd_parser` and do your development there.

## Project Status

This project is still in development. Currently it's not functional but the base classes should be feature-complete for partial use
in your custom implementation.

## Copyright

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. Ported from the pmx project by [kanriyu](https://github.com/kanryu/pmx), Licensed under Apache License 2.0.