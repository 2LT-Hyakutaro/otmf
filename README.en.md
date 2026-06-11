[![it](https://img.shields.io/badge/README-italiano-green.svg)](https://github.com/2LT-Hyakutaro/otmf/blob/main/README.md)

# `otmf` - One Tap, Multi Feature plugin for QField

This QField plugin allows you to instantly place a feature on the map, without having to go through the Feature Form every time.
Just fill in the feature fields in advance, and place it on the map or on your current location with the push of a button.
Allows for the creation of different standard features ("templates") that can be replicated at any time by pressing the corresponding button.

## Missing features

- Support for geometries other than `Point`
- Different colours for different features
- Ability to add more than two global attributes
- Ability to modify a template by long-pressing
- Template order

## Known bugs 
- "fid" bug (feature count increases by 2 the first time)

### example `templates`

```
[
  {
    "layer_name" : "cheese",
    "layer_color" : "yellow",
    "feature_name" : "venezuelan beaver cheese",
    "attributes" : {
      "origin" : "south america",
      "milk" : "beaver",
      "quantity" : 0
    }
  },
  {
    "layer_name" : "cheese",
    "layer_color" : "yellow",
    "feature_name" : "camembert",
    "attributes" : {
      "origin" : "france",
      "runny" : true
    }
  },
  {
    "layer_name" : "chocolate",
    "layer_color" : "brown",
    "feature name" : "crunchy frog",
    "attributes" : {
      "preservatives" : false,
      "bones" : true,
      "frog" : "dead"
    }
  }
]

```
