# Findit-for-xcode [![Build Status](https://travis-ci.org/rogermolas/findit-for-xcode.svg?branch=master)](https://travis-ci.org/rogermolas/findit-for-xcode) ![Status](https://img.shields.io/badge/status-active-brightgreen.svg?style=flat) [![license](https://img.shields.io/github/license/mashape/apistatus.svg?maxAge=2592000)](https://github.com/rogermolas/findit-for-xcode/blob/master/LICENSE)
[![Contact](https://img.shields.io/badge/contact-@roger_molas-yellowgreen.svg?style=flat)](https://twitter.com/roger_molas)
  Findit is a plug-in for browsing stackoverflow website inside XCode IDE.

![ FindIt Demo ](https://github.com/rogermolas/findit-for-xcode/blob/master/demo.gif)

## Support Xcode Versions
  - Xcode6
  - Xcode7

## Install
  - Using [Alcatraz]( https://github.com/alcatraz/Alcatraz )

## Manual build and install
  - Download source code and open Findit.xcodeproj with Xcode.
  - Select "Edit Scheme" and set "Build Configuration" as "Release"
  - Build it. It automatically installs the plugin into the correct directory.
  - Restart Xcode. (Make sure that the Xcode process is terminated entirely)

## Manual uninstall
  Delete the following directory:
  ```bash
  rm -rf ~/Library/Application Support/Developer/Shared/Xcode/Plug-ins/FindIt.xcplugin
  ```
## License

MIT License

Copyright (c) 2016 Roger Molas

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
