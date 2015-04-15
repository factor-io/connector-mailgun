[![Code Climate](https://codeclimate.com/github/factor-io/connector-mailgun/badges/gpa.svg)](https://codeclimate.com/github/factor-io/connector-mailgun)
[![Test Coverage](https://codeclimate.com/github/factor-io/connector-mailgun/badges/coverage.svg)](https://codeclimate.com/github/factor-io/connector-mailgun)
[![Build Status](https://travis-ci.org/factor-io/connector-mailgun.svg?branch=master)](https://travis-ci.org/factor-io/connector-mailgun)
[![Dependency Status](https://gemnasium.com/factor-io/connector-mailgun.svg)](https://gemnasium.com/factor-io/connector-mailgun)
[![Gem Version](https://badge.fury.io/rb/factor-connector-mailgun.png)](http://badge.fury.io/rb/factor-connector-mailgun)

Factor.io Mailgun Connector
======================

Factor.io Connector for integrating with Mailgun.

## Installation
Add this to your `Gemfile` in your [Connector](https://github.com/factor-io/connector)
```ruby
gem 'factor-connector-mailgun', '~> 0.0.3'
```

Add this to your `init.rb`  in your [Connector](https://github.com/factor-io/connector)

```ruby
require 'factor/connector/mailgun_messages'
```

The [Connectors README](https://github.com/factor-io/connector#running) shows you how to run the Connector Server with this new connector integrated.

## Running tests
These tests are functional, they will call out to your Mailgun account and take actions.

```shell
export MAILGUN_DOMAIN=<domain>
export MAILGUN_API_KEY=<api key>
bundle exec rake
```
