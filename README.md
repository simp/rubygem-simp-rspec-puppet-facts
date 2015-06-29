# simp-rspec-puppet-facts

[![Build Status](https://img.shields.io/travis/simp/simp-rspec-puppet-facts/master.svg)](https://travis-ci.org/simp/simp-rspec-puppet-facts)
[![Gem Version](https://img.shields.io/gem/v/simp-rspec-puppet-facts.svg)](https://rubygems.org/gems/simp-rspec-puppet-facts)


Simplify (ahem: "SIMPlify") your unit tests by looping on every supported Operating System and populating facts.

This gem acts as a shim in front of the most excellent [mcanevet/rspec-puppet-facts](https://github.com/mcanevet/rspec-puppet-facts) and can be used as a drop-in replacement when testing for SIMP.

## Motivation
The `on_supported_os` method provided by rspec-puppet-facts provides facts captured from actual systems (captured in a brilliantly elegant [Vagrantfile](https://github.com/mcanevet/rspec-puppet-facts/blob/master/facts/Vagrantfile)).  However, many SIMP tests require additional custom facts.
