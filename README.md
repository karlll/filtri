Filtri
======

Filtri is a tiny DSL for text substitution.

## Installation

    $ gem install filtri

## Usage

Define a set of substitution rules using `rule` and apply to an input string:


    f = filtri do
      rule /fo+/ => "bar"
      rule "baz" => "bug"
    end

    f.apply("foobazbarfoo")
    => "barbugbarbar"

Rules can also be read from a file:

File `foo.rules`:

     # this is a comment
     rule /fo+bar/ => "bazbag"
     rule /(a)+/ => '!!\1!!'
     rule /(b)+/ => '**\1**'

Load with `Filtri::load`:

    Filtri.load("foo.rules").apply("foobarfoobar")
    => "**b**!!a!!z**b**!!a!!g**b**!!a!!z**b**!!a!!g"

## Command line tool

A command line tool is included in this gem, `filtri`

### Usage

    Usage: filtri [options] [input]

    Options:
        -r, --rule STRING                Single rule
        -f, --file RULE_FILE             File containing rules
        -v, --version                    Version information
        -h, --help                       Help


### Examples

An example applying rules from the files `f1.rule` and `f2.rule` to the input files `input1` and `input2`

File `f1.rules`:

    rule /(foo+)/ => 'THIS WAS \1'
    rule /(ba+r)/ => 'THIS WAS \1'

File `f1.rules`:

    rule /(ba+z)/ => 'THIS WAS \1'
    rule /bag/ => 'THIS WAS BAG'

File `input1`:

    foooo
    baaaaaaaaaaaaaaaaz
    bag

File `input2`:

    and baaaaaaaaaaar

Running `filtri` as

    $ filtri -f f1.rules -f f2.rules input1 input2 > result.txt

..gives `result.txt`:

    THIS WAS foooo
    THIS WAS baaaaaaaaaaaaaaaaz
    THIS WAS BAG
    and THIS WAS baaaaaaaaaaar

Single rules can be provided using the option `-r`:

    $ echo "foo" | filtri -r '"foo" => "bar"'
    bar


## Syntax highlighting

Definitions for syntax highlighting of `.rule` files in Sublime Text 2 and TextMate is available (`resource/filtri_rules.tmLanguage`)

## Version information

* 0.1.0 - Added filtri tool and syntax highlighting
* 0.0.1 - Initial version

## License

Copyright (c) 2013 Karl L <karl@ninjacontrol.com>

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Author

Karl L, <karl@ninjacontrol.com>