## 1.0.4

* Increased the upper-bound of base to allow < 4.9. Now builds on
  GHC 7.10.1.
* Increased the upper-bound of aeson to allow < 0.10.

## 1.0.3

* Increase upper-bound of `wreq` to < 0.4. Thanks to @bflyblue for this change.

## 1.0.2

* Increase upper-bound of http-client to <0.5.
* Avoid ever posting `null`. Some metrics that are `Double` may post `null` if
  they are NaN or infinity - in this case we filter the submissions out.

## 1.0.1

* Relax dependencies for aeson, http-client, text, network and network-uri.
  Thanks to @k0001 (Renzo Carbonara) for this work.


## 1.0.0

* Initial release.
