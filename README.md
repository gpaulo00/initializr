
# Initializr
Initializr helps you to *automatically* install packages and configure your **system**.

This project is written in [Crystal](https://crystal-lang.org) language.

## Installation
Ensure that you've [Crystal](https://crystal-lang.org/) installed before start to using it. Now, you should clone this project by using:
```sh
git clone https://github.com/gpaulo00/initializr.git
```

Now, you are able to compile it into `bin/initializr` with **shards**:
```sh
shards build
```

## Usage
To get the usage of the *command-line* tool, run this:
```sh
initializr --help
```

## Running test
You can run the unit test with:
```sh
crystal spec
```

## Documentation
This project uses `crystal docs` to generate the documentation files at `docs/` folder.
I always try to document everything, so understand it is so easy. Also, it's very young
project yet.

## Contributing
1. Fork it ( https://github.com/gpaulo00/initializr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Versioning
I use [SemVer](http://semver.org/) for versioning.
For the versions available, see the tags on this repository.

## Contributors
- [gpaulo00](https://github.com/gpaulo00) Gustavo Paulo - creator, maintainer

## License
This project is licensed under the **MIT** License - see the [LICENSE](LICENSE) file for details
