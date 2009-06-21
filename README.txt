=Twig

* by Mike Zazaian
* http://twig-twitter.rubyforge.org

== DESCRIPTION:

An intelligent wrapper for the Twitter4r Rubygem.


== FEATURES/PROBLEMS:

== SYNOPSIS:

=== Intro



== REQUIREMENTS:

You must have rubygems installed to use Twig as a gem.  To install
Rubygems on a debian or ubuntu linux system, do:

  sudo aptitude update && sudo aptitude install rubygems

== INSTALL:

=== As a Rubygem

  sudo gem install --remote twig-twitter

Then, add Twig to your script with:

  require 'rubygems'
  require 'twig'

=== Directly into your script

If you want to include Twig directly into your script, you can
download Twig as a .tgz package from the Twig homepage at:

  http://twig-twitter.rubygems.org

Once you have the package, add Twig to your script's directory, add
the twig directory to your $LOAD_PATH variable...

  $LOAD_PATH << "./twig"

.. and require Twig at the top of your script:

  require 'twig'

== LICENSE:

(The MIT License)

Copyright (c) 2009 Mike Zazaian

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
