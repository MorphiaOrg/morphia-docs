+++
date = "2015-03-17T15:36:56Z"
title = "Installation Guide"
[menu.main]
  parent = "Getting Started"
  identifier = "Installation Guide"
  weight = 1
  pre = "<i class='fa'></i>"
+++

The recommended way to get started using Morphia in your project is with a dependency management system such as maven or gradle.  To use
 Morphia using either build tool, you will need to update your build configurations with the following information.

{{< install >}}

{{% notice info %}}
Morphia 2.0 requires Java 11 or greater.  Morphia has been tested on mongodb servers as old as 3.6.15 up through the most recent builds.
Morphia will likely work on older servers versions but those remain untested and no guarantees are made.
{{% /notice %}}
