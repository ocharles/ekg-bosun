## 1.0.15

### Other Changes

* Increased the upper bound of `base`, `network` and `http-client`.


## 1.0.14

### Other Changes

* Increased the upper bound of `aeson` to allow < 1.5.


## 1.0.13

### Other Changes

* Increased the upper bound of `base` to allow < 1.12.
* Increased the upper bound of `network` to allow < 2.8.

## 1.0.12

### Other Changes

* Increased the upper bound of `aeson` to allow < 1.4.

## 1.0.11

### Other Changes

* Increased the upper bound of `time`.

## 1.0.10

### Other Changes

* Increased the upper bound of `aeson`.

## 1.0.9

### Other Changes

* Increased the upper bound of `base`.

## 1.0.8

### Other Changes

* Increased the upper bound of `time` to allow < 1.9.
* Increased the upper bound of `wreq` to allow < 0.6.

## 1.0.7

* Increased the upper-bound of `aeson`, `http-client`, `time` and `vector`.

## 1.0.6

* Increased the upper-bound of `aeson`, `base` and `time`.

## 1.0.5

* Increased the upper-bound of aeson to allow < 0.11. Thanks to @bitemyapp for
  noticing and fixing this.
* Increased the upper-bound of vector to allow < 0.12.

## 1.0.4

* Increased the upper-bound of base to allow < 4.9. Now builds on
  GHC 7.10.1.
* Increased the upper-bound of aeson to allow < 0.10.
* Increased the upper-bound of time to allow < 1.6.
* Increased the upper-bound of wreq to allow < 0.5.

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
