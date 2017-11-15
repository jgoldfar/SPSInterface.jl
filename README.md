# SPSInterface

[![Build Status](https://travis-ci.org/jgoldfar/SPSInterface.jl.svg?branch=master)](https://travis-ci.org/jgoldfar/SPSInterface.jl)

[![Coverage Status](https://coveralls.io/repos/jgoldfar/SPSInterface.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/jgoldfar/SPSInterface.jl?branch=master)
[![codecov.io](http://codecov.io/github/jgoldfar/SPSInterface.jl/coverage.svg?branch=master)](http://codecov.io/github/jgoldfar/SPSInterface.jl?branch=master)

SPSInterface.jl uses [SPSBase.jl](https://github.com/jgoldfar/SPSBase.jl) and [SPSRunner.jl](https://github.com/jgoldfar/SPSRunner.jl) to provide a user-friendly interface for scheduling problem solvers.

Version: v0.0

## Dependencies/Setup

* TeXLive (or at least BasicTeX) is required to build the documentation.

* This repository needs to be on your `JULIA_PKGDIR`.

* Note: On OSX, apparently CoinOptServices does not find the Homebrew-built libraries correctly, so they have to be built from source.

## Roadmap

### v1.0

* Import/export story:

* * Lightweight DSL allowing input in a flat file format

* * Export to same file format


### v2.0

* Import/export story:

* * import availability from GCal -> flat file format

* * export directly to GCal or iCal format

## Who do I talk to? ##

* Jonathan Goldfarb (jgoldfar@my.fit.edu)